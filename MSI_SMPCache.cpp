#include "MSI_SMPCache.h"

//bool enable_prints=0;
int main_memory_size_used=0;
int main_memory_size_used_max=0;

linedata_t empty_ld = linedata_t();

// ================================================================
// *****CONSTRUCTOR
// ================================================================
MSI_SMPCache::MSI_SMPCache(int cpuid,
                           std::vector<SMPCache * > * same,    //siblings
                           SMPCache * next,                    //parent
                           std::vector<SMPCache * > * prev,    //children
                           bool isxor,
                           int csize,
                           int cassoc,
                           int cbsize,
                           int caddressable,
                           const char * repPol,
                           bool cskew) :
  SMPCache(cpuid,same,next,prev){

  printf("Making a MSI cache with cpuid %d\n",cpuid);
  CacheGeneric<MSI_SMPCacheState> *c =
    CacheGeneric<MSI_SMPCacheState>::create(csize,
                                            cassoc,
                                            cbsize,
                                            caddressable,
                                            repPol,
                                            isxor,
                                            cskew);
  cache = (CacheGeneric<StateGeneric<> >*)c;

}



// ================================================================
// *****FILL LINE
// ================================================================

void MSI_SMPCache::fillLine(uint64_t addr, uint32_t msi_state, linedata_t val=linedata_t()){

  if(enable_prints) printf("%d::::PULKIT entering fillline:: addr=%lx\n",this->getCPUId(),addr);
  MSI_SMPCacheState *st;
  int mytry=0;

  /*Loop until you find an appropriate line to replace*/
  do{

    /*Find line based on repl-policy*/
    st = (MSI_SMPCacheState *)cache->findLine2Replace(addr);
    if (st==NULL){
      printf("EXIT --- no line to replace\n");
      exit(1);
    }

    /*Line is empty*/
    if (!st->isValid() && !st->isValid_paired()){
      st->setTag(cache->calcTag(addr));
      st->setData(val);
      st->setData_paired(empty_ld);
      st->changeStateTo(MSI_SHARED);
      break;
    }

    /* Case: (A,-) */
    else if(st->isValid() && !st->isValid_paired()){ //non-xor cache
      MSI_SMPCache::RemoteReadService rrs = children_readRemoteAction(cache->calcAddr4Tag(st->getTag()));
      if(!rrs.providedData) {
        if(parent==NULL){
          printf("EXIT --- replacement in main memory, increase size1\n");
          exit(1);
        }
        parent->writeLine(cache->calcAddr4Tag(st->getTag()),st->getState(),st->getData_xor());
        numReplacements++;

        // valid for all cases
        st->setTag(cache->calcTag(addr));
        st->setData(val);
        st->setData_paired(empty_ld);
        st->changeStateTo(MSI_SHARED);
        break;
      }
    }

    /* Case: (A,-) */
    else if(!st->isValid() && st->isValid_paired()){
      linedata_t ld;
      bool dirty = st->getState_paired() == MSI_MODIFIED;
      MSI_SMPCache::RemoteReadService rrs = children_readRemoteAction(cache->calcAddr4Tag(st->getTag_paired()));

      if(rrs.providedData) {ld = rrs.linedata;       numChildrenRequests_total[0]++;}
      else                 ld = st->getData_xor();
      
      if (dirty && !rrs.providedData) { // make it clean if dirty+LastCopy
        if(parent==NULL){
          printf("EXIT --- replacement in last level (main memory), increase size2\n");
          exit(1);
        }
        parent->writeLine(cache->calcAddr4Tag(st->getTag_paired()),MSI_MODIFIED,st->getData_xor());
        st->changeStateTo_paired(MSI_SHARED);
      }

      // valid for all cases
      st->setTag(cache->calcTag(addr));
      st->setData(val);
      st->setData_paired(ld);
      st->changeStateTo(MSI_SHARED);
      break;
    }

    
    /* Case: (A,B) */
    else if (st->isValid() && st->isValid_paired()) {
      
      MSI_SMPCache::RemoteReadService rrs_A = children_readRemoteAction(cache->calcAddr4Tag(st->getTag()));
      MSI_SMPCache::RemoteReadService rrs_B = children_readRemoteAction(cache->calcAddr4Tag(st->getTag_paired()));

      if(!rrs_A.providedData && !rrs_B.providedData){     /* (A(C+NS),B(C+NS))*/ // SILENT EVICT BOTH
        st->setTag(cache->calcTag(addr));
        st->setData(val);
        st->setData_paired(empty_ld);
        st->changeStateTo(MSI_SHARED);
        st->invalidate_paired();
        break;
      }

      else if (rrs_A.providedData && rrs_B.providedData){ /* (A(X+S),B(X+S)) */ // A,B has sharers, can't evict any one
        // Don't choose this. We have to maintain inclusiveness
      }

      else if (rrs_A.providedData){                       /* (A(X+S),B(C+NS))*/ // A has sharers, keep A, evict B
        st->setTag_paired(cache->calcTag(addr));
        st->setData_paired(val);
        st->setData(rrs_A.linedata);
        numChildrenRequests_total[1]++;
        st->changeStateTo_paired(MSI_SHARED);
        break;
      }

      else if (rrs_B.providedData){                       /* (A(C+NS),B(X+S))*/ // B has sharers, keep B, evict A
        st->setTag(cache->calcTag(addr));
        st->setData(val);
        st->setData_paired(rrs_B.linedata);
        numChildrenRequests_total[1]++;
        st->changeStateTo(MSI_SHARED);
        break;
      }

      else {
        printf("EXIT --- not expected to reach here\n");
        exit(1);
      }
    }
    mytry++;
  }while(mytry<1000);
  if (mytry==1000) {
    exit(1);
  }
}


// ================================================================
// *****readRemoteAction (READ SIBLINGS)
// ================================================================
MSI_SMPCache::RemoteReadService MSI_SMPCache::readRemoteAction(uint64_t addr){

  /*This method implements snoop behavior on all the other
   *caches that this cache might be interacting with*/

  /*Loop over the other caches in the simulation*/
  std::vector<SMPCache * >::iterator cacheIter;
  std::vector<SMPCache * >::iterator lastCacheIter;
  for(    cacheIter = this->getCacheVector()->begin(),
      lastCacheIter = this->getCacheVector()->end();
      cacheIter != lastCacheIter;
      cacheIter++){

    /*Get a pointer to the other cache*/
    MSI_SMPCache *otherCache = (MSI_SMPCache*)*cacheIter;
    if(otherCache->getCPUId() == this->getCPUId()){

      /*We don't want to snoop our own access*/
      continue;

    }

    /*Get the state of the block this addr maps to in the other cache*/
    MSI_SMPCacheState* otherState =
      (MSI_SMPCacheState *)otherCache->cache->findLine(addr);

    /*If otherState == NULL here, the tags didn't match, so the
     *other cache didn't have this line cached*/
    if(otherState){
      /*The tags matched -- need to do snoop actions*/

      /*Other cache has recently written the line*/
      if(otherState->getState() == MSI_MODIFIED){

        /*Modified transitions to Shared on a remote Read*/
        otherState->changeStateTo(MSI_SHARED);

        /*Return a Remote Read Service indicating that
         *1)The line was not shared (the false param)
         *2)The line was provided by otherCache, as only it had it cached
         */
        return MSI_SMPCache::RemoteReadService(false,true,otherState->getData_xor()); // no need to check for MSB, as it is in modified state

        /*Other cache has recently read the line*/
      }else if(otherState->getState() == MSI_SHARED && otherState->isValid()){

        /*Return a Remote Read Service indicating that
         *1)The line was shared (the true param)
         *2)The line was provided by otherCache
         */
        return MSI_SMPCache::RemoteReadService(true,true,otherState->getData_xor());

        /*Line was cached, but invalid*/
      }else if(otherState->getState() == MSI_INVALID){

        /*Do Nothing*/

      }

    }/*Else: Tag didn't match. Nothing to do for this cache*/

  }/*Done with other caches*/

  /*If all other caches were MSI_INVALID*/
  return MSI_SMPCache::RemoteReadService(false,false);
}


// ================================================================
// *****READ LINE
// ================================================================
linedata_t MSI_SMPCache::readLine(uint64_t addr){

  MSI_SMPCacheState *st = (MSI_SMPCacheState *)cache->findLine(addr);
  linedata_t ld = linedata_t();

  if(!st || (st && !(st->isValid())) ){

    /*Update event counter for read misses*/
    numReadMisses++;
    //printf("READ MISS -- CPU %d, Address:%lx\n", this->getCPUId(), addr);

    MSI_SMPCache::RemoteReadService rrs = readRemoteAction(addr);
    numReadRequestsSent++;

    if(rrs.providedData){

      // If it was shared or modified elsewhere, *the line was provided by another cache. *Update these counters to reflect that
      numReadMissesServicedByOthers++;

      if(rrs.isShared){
        numReadMissesServicedByShared++;
      }else{
        numReadMissesServicedByModified++;
      }

    }
    else { // Get it from the next (parent)) level in the hierarchy

      if(parent==NULL){
        // printf("EXIT --- last level reached\n");
        // exit(1);
      }
      else
        ld = parent->readLine(addr);
    }

    fillLine(addr, MSI_SHARED, ld);
  }
  else{ // HIT
    numReadHits++;
    
    if (st->isValid_paired()==0){                                                         // (Ac/-)normal cache or unpaired line
      ld = st->getData_xor();
    }
    else { // xor line for sure
      MSI_SMPCache::RemoteReadService rrs = children_readRemoteAction(cache->calcAddr4Tag(st->getTag_paired()));
      if (rrs.providedData){// sharers are present
        if (st->getState_paired()==MSI_MODIFIED)                                        // (Ac/Bd) paired with dirty line, go to parent
          ld = parent->readLine(addr); 
        else {                                                                        // (Ac/BcS) sharers are clean, used the data from sharers to un-xor the xor-data
          ld = (rrs.linedata ^ st->getData_xor());
          numChildrenRequests++;
        }
      }
      else if (st->getState_paired()==MSI_SHARED) {                                      // (Ac/BcNS) no way to un-xor the data, go main memory
        ld = parent->readLine(addr);
      }
      else {
        printf("EXIT --- UNEXPECTED CASE, paired DIRTY DATA with no sharers in xor line\n");
        enable_prints = true;
        enable_prints2 = true;
        (MSI_SMPCacheState *)cache->findLine(addr);
        exit(1);
      }
    }
  }

  return ld;

}

// ================================================================
// *****readRemoteAction (READ CHILDREN)
// ================================================================
MSI_SMPCache::RemoteReadService MSI_SMPCache::children_readRemoteAction(uint64_t addr){

  /*This method implements snoop behavior on all the other
   *caches that this cache might be interacting with*/

  /*Loop over the other caches in the simulation*/
  std::vector<SMPCache * >::iterator cacheIter;
  std::vector<SMPCache * >::iterator lastCacheIter;

  if (children == NULL) return MSI_SMPCache::RemoteReadService(false,false);

  for(    cacheIter = children->begin(),
      lastCacheIter = children->end();
      cacheIter != lastCacheIter;
      cacheIter++){

    /*Get a pointer to the other cache*/
    MSI_SMPCache *otherCache = (MSI_SMPCache*)*cacheIter;

    /*Get the state of the block this addr maps to in the other cache*/
    MSI_SMPCacheState* otherState = (MSI_SMPCacheState *)otherCache->cache->findLine(addr);

    // If otherState == NULL here, the tags didn't match, so the other cache didn't have this line cached
    if(otherState)
      if(!(otherState->getState() == MSI_INVALID))
        return MSI_SMPCache::RemoteReadService(otherState->getState() == MSI_SHARED,true,otherState->getData_xor()); // no need to check for MSB, as it is in modified state
  }

  /*If all other caches were MSI_INVALID*/
  return MSI_SMPCache::RemoteReadService(false,false);
}


// ================================================================
// *****READ LINE (CHILDREN)
// ================================================================
linedata_t MSI_SMPCache::children_readLine(uint64_t addr){
  MSI_SMPCache::RemoteReadService rrs = children_readRemoteAction(addr);
  linedata_t ld = linedata_t();
  if(!rrs.providedData){
    if(enable_prints) printf("Data not found in L1\n");
  }
  else{
    ld = rrs.linedata;
  }
  return ld;
}

// ================================================================
// *****WRITE LINE
// ================================================================
void MSI_SMPCache::writeLine(uint64_t addr, uint32_t msi_state, linedata_t ld){ // only used for evicted lines due to replacement
  if(enable_prints) printf("%d::::PULKIT entering writeline:: addr=%lx\n",this->getCPUId(),addr);
  MSI_SMPCacheState *st = (MSI_SMPCacheState *)cache->findLine(addr);
  numWritebacksReceived++;

  if(parent!=NULL && (!st || (st && !(st->isValid()))) ){ //Write Miss -> ERROR
    printf("EXIT --- inclusiveness not maintained\n");
    exit(1);
    fillLine(addr,MSI_MODIFIED,ld);
  }

  else{ //Write Hit
    if(enable_prints) printf("%d::::PULKIT entering writeline1:: addr=%lx\n",this->getCPUId(),addr);
    numWriteHits++;
    
    if (st->getState()==MSI_SHARED && msi_state==MSI_SHARED) return;               // (xx) clean
    
    if (st->isValid_paired()==0){                                                 // (--) unpaired line
      st->setData(ld);
      st->setData_paired(empty_ld);
      st->changeStateTo(MSI_MODIFIED);
      return;
    }

    MSI_SMPCache::RemoteReadService rrs = children_readRemoteAction(cache->calcAddr4Tag(st->getTag_paired()));
    if (!rrs.providedData){// no sharers are present
      if (st->getState_paired()==MSI_MODIFIED) {                                  // (BdNS) paired but no sharers, ERROR
        printf("EXIT --- assumption voilated 'dirty will never be paired'\n");
        enable_prints = true;
        enable_prints2 = true;
        (MSI_SMPCacheState *)cache->findLine(addr);
        exit(1);
      }
      
      st->setData(ld);                                                            // (BcNS) paired but no sharers, discard B
      st->setData_paired(empty_ld);
      st->changeStateTo(MSI_MODIFIED);
      st->invalidate_paired();
      return;
    }

    // XOR CACHE NEVER PAIRS THE ONLY COPY OF DIRTY DATA
    if (parent!=NULL) {// dirty line and paired, writeback to parent, and then consider this line clean
      parent->writeLine(addr,msi_state,ld);
      msi_state = MSI_SHARED;
    }
    
    st->setData(ld);                                                          // (BxS) paired and has sharers
    st->setData_paired(rrs.linedata);                                         // (BxS) paired and has sharers
    numChildrenRequests_total[2]++;
    st->changeStateTo(MSI_SHARED);
    return;
  }
  
  // FIXME --- maintain statistics
}




// ================================================================
// *****READ WORD (only to be called by MCS.cpp)
// ================================================================
uint32_t MSI_SMPCache::readWord(uint32_t rdPC, uint64_t addr){

  if(enable_prints) printf("%d::::PULKIT entered readline:: READING LINE addr=%lx\n",this->getCPUId(),addr);

  MSI_SMPCacheState *st = (MSI_SMPCacheState *)cache->findLine(addr);
  linedata_t ld;

  if(!st || (st && !(st->isValid())) ){ //Read Miss

    /*Update event counter for read misses*/
    numReadMisses++;

    if(st){  // Tag matched, but state was invalid
      numReadOnInvalidMisses++;
      //printf("READ MISS ON INVALID -- CPU %d, Address:%lx\n", this->getCPUId(), addr);
    }

    MSI_SMPCache::RemoteReadService rrs = readRemoteAction(addr);
    numReadRequestsSent++;

    if(rrs.providedData){// the line was provided by another cache. Update these counters to reflect that
      numReadMissesServicedByOthers++;

      if(rrs.isShared){
        numReadMissesServicedByShared++;
      }else{
        numReadMissesServicedByModified++;
      }
      ld = rrs.linedata;
    }
    else { // Get it from the next (parent) level in the hierarchy
      if (parent!=NULL)
        ld = parent->readLine(addr);
      else printf("%d::::NULL PARENT SEEN\n",this->getCPUId());
    }

    if(st){  // stale data present, compare with the coherent data for T/F sharing stats
      uint32_t lcd, rcd; //local cache data, remote cache data
      lcd = st->getData(cache->calcOffset(addr)); //NEEDS CHECK
      /*True & False Sharing / Approximation Stats*/
      rcd = ld.data[cache->calcOffset(addr)];
      if(enable_prints) printf("%d::::PULKIT TF STATS readline:: READING LINE addr=%lx, offset:%d\n",this->getCPUId(),addr,cache->calcOffset(addr));
      if (lcd == rcd) {
        numFalseSharing++;
        numCorrectSpeculations++;
        if(enable_prints) printf("False Sharing++\n");}
      else {
        numTrueSharing++;
        numIncorrectSpeculations++;
        if(enable_prints) printf("True Sharing++\n");}
    }

    /*Fill the line*/
    fillLine(addr,MSI_SHARED,ld);
    if(enable_prints) printf("%d::::PULKIT MISS readline:: READING LINE addr=%lx\n",this->getCPUId(),addr);

  }else{

    /*Read Hit - any state but Invalid*/
    numReadHits++;
    if(enable_prints) printf("%d::::PULKIT HIT readline:: READING LINE addr=%lx\n",this->getCPUId(),addr);

  }
  if (st==NULL){
    MSI_SMPCacheState *st2 = (MSI_SMPCacheState *)cache->findLine(addr);
    return st2->getData(cache->calcOffset(addr));
  }
  else
    return st->getData(cache->calcOffset(addr));
}



// ================================================================
// *****INVALIDATE LINES In SIBLINGS (writeRemoteAction)
// ================================================================
MSI_SMPCache::InvalidateReply  MSI_SMPCache::writeRemoteAction(uint64_t addr){

  /*This method implements snoop behavior on all the other caches that this cache might be interacting with*/
  MSI_SMPCache::InvalidateReply reply = MSI_SMPCache::InvalidateReply(true);

  /*Loop over all other caches*/
  std::vector<SMPCache * >::iterator cacheIter;
  std::vector<SMPCache * >::iterator lastCacheIter;
  for(cacheIter = this->getCacheVector()->begin(),
        lastCacheIter = this->getCacheVector()->end();
      cacheIter != lastCacheIter;
      cacheIter++){

    MSI_SMPCache *otherCache = (MSI_SMPCache*)*cacheIter;
    if(otherCache->getCPUId() == this->getCPUId()){
      /*We don't snoop ourselves*/
      continue;
    }

    /*Get the line from the current other cache*/
    MSI_SMPCacheState* otherState =
      (MSI_SMPCacheState *)otherCache->cache->findLine(addr);

    /*if it is cached by otherCache*/
    if(otherState && otherState->isValid()){

      /*The reply contains data, so "empty" is false*/
      reply.empty = false;
      reply.linedata = otherState->getData_xor();

      /*Invalidate the line, because we're writing*/
      otherState->invalidate();
    }
  }

  return reply;
}


void MSI_SMPCache::find_and_make_modified(uint64_t addr){ // to be called from children
  MSI_SMPCacheState * st = (MSI_SMPCacheState *)cache->findLine(addr);
  if(st && st->isValid() && st->getState()==MSI_SHARED){
    st->changeStateTo(MSI_MODIFIED);
  }
}

// ================================================================
// *****WRITE WORD (only to be called by MCS.cpp)
// ================================================================
void MSI_SMPCache::writeWord(uint32_t wrPC, uint64_t addr, uint32_t val=0){

  /*Find the line to which this address maps*/
  MSI_SMPCacheState * st = (MSI_SMPCacheState *)cache->findLine(addr);

  if(!st || (st && !(st->isValid())) ){
    numWriteMisses++;

    if(st){ // We're writing to an invalid line
      numWriteOnInvalidMisses++;
    }

    // Let the other caches snoop this write access and update their state accordingly.  This action is effectively putting the write on the bus.
    MSI_SMPCache::InvalidateReply inv_ack = writeRemoteAction(addr);
    numInvalidatesSent++;
    if (inv_ack.empty)
      inv_ack.linedata = parent->readLine(addr);
    inv_ack.linedata.data[cache->calcOffset(addr)] = val;

    /*Fill the line with the new written block*/
    if(enable_prints) printf("%d::::PULKIT exiting writeline (miss):: WRITING word addr=%lx & val=%x\n",this->getCPUId(),addr,val);
    fillLine(addr,MSI_MODIFIED,inv_ack.linedata);
    parent->find_and_make_modified(addr);
    return;

  }else if(st->getState() == MSI_SHARED){
    /*If the block is shared and we're writing, we've incurred a coherence
     *miss.  We need to upgrade to Modified to write, and all other
     *copies must be invalidated
     */
    numWriteMisses++;

    /*Write-on-shared Coherence Misses*/
    numWriteOnSharedMisses++;

    /*Let the other sharers snoop this write, and invalidate themselves*/
    writeRemoteAction(addr);
    numInvalidatesSent++;

    uint32_t prevData = st->getData(cache->calcOffset(addr));
    if (prevData == val) {
      numSilentStores++;
    }
    /*Change the state of the line to Modified to reflect the write*/
    st->changeStateTo(MSI_MODIFIED);
    st->setData(val,cache->calcOffset(addr));
    parent->find_and_make_modified(addr);
    if(enable_prints) printf("%d::::PULKIT exiting writeline (shared miss):: WRITING word addr=%lx & val=%x\n",this->getCPUId(),addr,val);
    return;

  }else{ //Write Hit

    /*Already have it writable: No coherence action required!*/
    numWriteHits++;
    if(enable_prints) printf("%d::::PULKIT exiting writeline (mod hit):: WRITING word addr=%lx & val=%x\n",this->getCPUId(),addr,val);

    uint32_t prevData = st->getData(cache->calcOffset(addr));
    if (prevData == val) {
      numSilentStores++;
    }

    st->setData(val,cache->calcOffset(addr));
    return;
  }

}

char *MSI_SMPCache::Identify(){
  return (char *)"MSI Cache Coherence";
}

MSI_SMPCache::~MSI_SMPCache(){

}

extern "C" SMPCache *Create(int num, std::vector<SMPCache*> *same, SMPCache* next, std::vector<SMPCache*> *prev, bool isxor, int csize, int casso, int bs, int addrble, const char *repl, bool skw){
  //cvec->same, main->next
  return new MSI_SMPCache(num,same,next,prev,isxor,csize,casso,bs,addrble,repl,skw);

}
