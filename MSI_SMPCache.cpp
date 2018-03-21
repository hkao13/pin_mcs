#include "MSI_SMPCache.h"

//bool enable_prints=0;
int main_memory_size_used=0;
int main_memory_size_used_max=0;

MSI_SMPCache::MSI_SMPCache(int cpuid, 
                           std::vector<SMPCache * > * cacheVector,
			   SMPCache * main, 
                           int csize, 
                           int cassoc, 
                           int cbsize, 
                           int caddressable, 
                           const char * repPol, 
                           bool cskew) : 
                             SMPCache(cpuid,cacheVector,main){
  
  printf("Making a MSI cache with cpuid %d\n",cpuid);
  CacheGeneric<MSI_SMPCacheState> *c = 
    CacheGeneric<MSI_SMPCacheState>::create(csize, 
                                            cassoc, 
                                            cbsize, 
                                            caddressable, 
                                            repPol, 
                                            cskew);
  cache = (CacheGeneric<StateGeneric<> >*)c; 

}

void MSI_SMPCache::fillLine(uint64_t addr, uint32_t msi_state, linedata_t val=linedata_t()){

  //this gets the state of whatever line this address maps to 
  MSI_SMPCacheState *st = (MSI_SMPCacheState *)cache->findLine2Replace(addr); 

  if(enable_prints) printf("%d::::PULKIT entering fillline:: addr=%lx\n",this->getCPUId(),addr);

  if(st==0){
    if(enable_prints) printf("%d::::PULKIT entering state0:: addr=%lx\n",this->getCPUId(),addr);
    /*No state*/ exit(1);
    return;
  }

  if ((!st->islineInvalid) && (st->isDirty())) { // line valid, push it into main and dirty bit is set.
    MSI_SMPCacheState *st3 = (MSI_SMPCacheState *)main_memory->cache->findLine2Replace(addr);
    if (!st3->islineInvalid) { // main_memory full. error out
      printf("1 %x\n",st3->getData(0));
      printf("2 %x\n",st3->getTag());
      printf("3 %d\n",st3->islineInvalid);
      printf("main memory full. please increase. not supported\n");
      exit(1);
    }
    else {
      st3->setTag(st->getTag());
      st3->setData(st->getData());
      st3->changeStateTo(MSI_SHARED);
      if(enable_prints) printf("pushed into main mem with tag=%x\n",st3->getTag());
      main_memory_size_used++;
      numWriteBacks++;
      if (main_memory_size_used_max < main_memory_size_used) {main_memory_size_used_max = main_memory_size_used; if(enable_prints) printf("%d\n",main_memory_size_used_max);}
    }
  }
  
  /*Set the tags to the tags for the newly cached block*/
  st->setTag(cache->calcTag(addr));
  st->setData(val);

  if(enable_prints) printf("%d::::HENRY value set in fillline:: addr=%lx, val=%x\n",this->getCPUId(),addr, st->getData(cache->calcOffset(addr)));

  /*Set the state of the block to the msi_state passed in*/
  st->changeStateTo((MSIState_t)msi_state);
  return;

  if(enable_prints) printf("%d::::PULKIT exiting fillline:: addr=%lx\n",this->getCPUId(),addr);

}
  

MSI_SMPCache::RemoteReadService MSI_SMPCache::readRemoteAction(uint64_t addr){

  /*This method implements snoop behavior on all the other 
   *caches that this cache might be interacting with*/

  /*Loop over the other caches in the simulation*/
  std::vector<SMPCache * >::iterator cacheIter;
  std::vector<SMPCache * >::iterator lastCacheIter;
  for(cacheIter = this->getCacheVector()->begin(), 
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
        return MSI_SMPCache::RemoteReadService(false,true,otherState->getData(),otherState->isDirty()); // no need to check for MSB, as it is in modified state

      /*Other cache has recently read the line*/
      }else if(otherState->getState() == MSI_SHARED && otherState->isValid()){  
        
        /*Return a Remote Read Service indicating that 
         *1)The line was shared (the true param)
         *2)The line was provided by otherCache 
        */
	return MSI_SMPCache::RemoteReadService(true,true,otherState->getData(), otherState->isDirty());

      /*Line was cached, but invalid*/
      }else if(otherState->getState() == MSI_INVALID){ 

        /*Do Nothing*/

      }

    }/*Else: Tag didn't match. Nothing to do for this cache*/

  }/*Done with other caches*/

  /*If all other caches were MSI_INVALID*/
  return MSI_SMPCache::RemoteReadService(false,false);
}


uint32_t MSI_SMPCache::readLine(uint32_t rdPC, uint64_t addr){
  /*
   *This method implements actions taken on a read access to address addr
   *at instruction rdPC
  */

  if(enable_prints) printf("%d::::PULKIT entered readline:: READING LINE addr=%lx\n",this->getCPUId(),addr);
  /*Get the state of the line to which this address maps*/
  MSI_SMPCacheState *st = 
    (MSI_SMPCacheState *)cache->findLine(addr);    
  
  /*Read Miss - tags didn't match, or line is invalid*/
  if(!st || (st && !(st->isValid())) ){

    /*Update event counter for read misses*/
    numReadMisses++;
    //printf("READ MISS -- CPU %d, Address:%lx\n", this->getCPUId(), addr);

    if(st){

      /*Tag matched, but state was invalid*/
      numReadOnInvalidMisses++;
      //printf("READ MISS ON INVALID -- CPU %d, Address:%lx\n", this->getCPUId(), addr);

      // VICTOR
      //------------------------------------------------------CURRENT CHANGES!------------------------------------------------------
      /*Check if it's true or false sharing*/
      uint32_t lcd, rcd; //local cache data, remote cache data
      lcd = st->getData(cache->calcOffset(addr));         //NEEDS CHECK
      
      //Find where the data actually is
      
      /*This method implements snoop behavior on all the other 
      *caches that this cache might be interacting with*/
      
      /*Loop over the other caches in the simulation*/
      std::vector<SMPCache * >::iterator cacheIter;
      std::vector<SMPCache * >::iterator lastCacheIter;
      for(cacheIter = this->getCacheVector()->begin(), 
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

          /*Other cache has recently written or read the line*/
          if( otherState->isValid() ){        //NEEDS CHECK - Can it be shared and not be valid?
          
            //MSI_SMPCacheState* otherData = 
            //  (MSI_SMPCacheState *)otherCache->cache->findLine(addr);
          
            rcd = otherState->getData(cache->calcOffset(addr));    //NEEDS CHECK
            
            if ( (lcd == rcd) ){
              numFalseSharing++;
            }
            else {
              numTrueSharing++;
            }
            
            //printf("Number of false sharings: %d, lcd: %x, rcd: %x\n", numFalseSharing, lcd, rcd);
            //printf("Number of true sharings: %d, lcd: %x, rcd: %x\n", numTrueSharing, lcd, rcd);

            break;
            
          }

        }/*Else: Tag didn't match. Nothing to do for this cache*/

      }/*Done with other caches*/
    //------------------------------------------------------CURRENT CHANGES!------------------------------------------------------
    }

    /*Make the other caches snoop this access 
     *and get a remote read service object describing what happened.
     *This is effectively putting the access on the bus.
    */
    MSI_SMPCache::RemoteReadService rrs = readRemoteAction(addr);
    numReadRequestsSent++;
    
    if(rrs.providedData){

      /*If it was shared or modified elsewhere,
       *the line was provided by another cache.
       *Update these counters to reflect that
      */
      numReadMissesServicedByOthers++;

      if(rrs.isShared){
        numReadMissesServicedByShared++;
      }else{
        numReadMissesServicedByModified++;
      }

    }
    else { // get from main memory
      MSI_SMPCacheState* st3 = (MSI_SMPCacheState *)main_memory->cache->findLine(addr);
      if (st3) {
        rrs.linedata     = st3->getData();
        rrs.providedData = true;
        if(enable_prints) printf("pulled from main mem with tag=%x\n",st3->getTag());
        main_memory_size_used--;
        st3->invalidate();
      }
      else printf("ERROR - address accessed before simulated system saw init val\n");
    }
      

    /*Fill the line*/
    fillLine(addr,MSI_SHARED,rrs.linedata); // FIXME-PA - get actual data from somewhere?? required? can we assume that the benchmark will init all data after malloc
    if(enable_prints) printf("%d::::PULKIT MISS readline:: READING LINE addr=%lx\n",this->getCPUId(),addr);

  }else{

    /*Read Hit - any state but Invalid*/
    numReadHits++; 
    if(enable_prints) printf("%d::::PULKIT HIT readline:: READING LINE addr=%lx\n",this->getCPUId(),addr);

  }
  if (st==NULL){
    MSI_SMPCacheState *st2 = (MSI_SMPCacheState *)cache->findLine(addr);    
    // if(enable_prints)printf("%d::::PULKIT exiting readline:: READING LINE addr=%lx %d\n",this->getCPUId(),addr, st2->getData(cache->calcOffset(addr)));
    return st2->getData(cache->calcOffset(addr));
  }
  else
    return st->getData(cache->calcOffset(addr));
}


MSI_SMPCache::InvalidateReply  MSI_SMPCache::writeRemoteAction(uint64_t addr, uint32_t val=0){ // val is passed for rmw
    
    /*This method implements snoop behavior on all the other 
     *caches that this cache might be interacting with*/
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
	reply.linedata.data[otherCache->cache->calcOffset(addr)] = val;
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
          otherState->setData(val,otherCache->cache->calcOffset(addr));
          reply.linedata = otherState->getData();

          /*Invalidate the line, because we're writing*/
          otherState->invalidate();
      }

    }/*done with other caches*/

    // If cache line is supplied by other caches, then return.
    if (reply.empty == false) {
      return reply;
    }

    // checking in main memory
    MSI_SMPCacheState* st3 = (MSI_SMPCacheState *)main_memory->cache->findLine(addr);
    if(st3!=NULL){
      reply.empty = false;
      st3->setData(val,main_memory->cache->calcOffset(addr));
      reply.linedata     = st3->getData();
      st3->invalidate();
    }

    /*Empty=true indicates that no other cache 
    *had the line or there were no other caches
    * 
    *This data in this object is not used as is, 
    *but it might be useful if you plan to extend 
    *this simulator, so i left it in.
    */
    return reply;
}


void MSI_SMPCache::writeLine(uint32_t wrPC, uint64_t addr, uint32_t val=0){
  /*This method implements actions taken when instruction wrPC
   *writes to memory location addr*/

  /*Find the line to which this address maps*/ 
  MSI_SMPCacheState * st = (MSI_SMPCacheState *)cache->findLine(addr);    

  /*
   *If the tags didn't match, or the line was invalid, it is a 
   *write miss
   */ 
  if(!st || (st && !(st->isValid())) ){ 

    numWriteMisses++;
    
    if(st){

      /*We're writing to an invalid line*/
      numWriteOnInvalidMisses++;

    }
 
    /*
     * Let the other caches snoop this write access and update their
     * state accordingly.  This action is effectively putting the write
     * on the bus.
     */ 
    MSI_SMPCache::InvalidateReply inv_ack = writeRemoteAction(addr,val);
    numInvalidatesSent++;

    /*Fill the line with the new written block*/
    if(enable_prints) printf("%d::::PULKIT exiting writeline (miss):: WRITING word addr=%lx & val=%x\n",this->getCPUId(),addr,val);
    fillLine(addr,MSI_MODIFIED,inv_ack.linedata);
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
    MSI_SMPCache::InvalidateReply inv_ack = writeRemoteAction(addr,val); inv_ack=inv_ack;
    numInvalidatesSent++;

    /*Change the state of the line to Modified to reflect the write*/
    st->changeStateTo(MSI_MODIFIED);
    st->setData(val,cache->calcOffset(addr));
    if(enable_prints) printf("%d::::PULKIT exiting writeline (shared miss):: WRITING word addr=%lx & val=%x\n",this->getCPUId(),addr,val);
    return;

  }else{ //Write Hit

    /*Already have it writable: No coherence action required!*/
    numWriteHits++;
    if(enable_prints) printf("%d::::PULKIT exiting writeline (mod hit):: WRITING word addr=%lx & val=%x\n",this->getCPUId(),addr,val);
    st->setData(val,cache->calcOffset(addr));
    return;

  }

}

char *MSI_SMPCache::Identify(){
  return (char *)"MSI Cache Coherence";
}

MSI_SMPCache::~MSI_SMPCache(){

}

extern "C" SMPCache *Create(int num, std::vector<SMPCache*> *cvec, SMPCache* main, int csize, int casso, int bs, int addrble, const char *repl, bool skw){

  return new MSI_SMPCache(num,cvec,main,csize,casso,bs,addrble,repl,skw);

}
