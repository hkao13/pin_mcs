#include "MSI_SMPCache.h"

#define APPROX_THRESHOLD 0.5

#define ENABLE_CD_W 0
#define ENABLE_CD_IA 0

//bool enable_prints=0;
int main_memory_size_used=0;
int main_memory_size_used_max=0;

  
// ================================================================
// *****CONSTRUCTOR
// ================================================================
MSI_SMPCache::MSI_SMPCache(int cpuid, 
                           std::vector<SMPCache * > * same,	//siblings
													 SMPCache * next, 								//parent
													 std::vector<SMPCache * > * prev,	//children
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
                                            cskew);
  cache = (CacheGeneric<StateGeneric<> >*)c; 

}


  
// ================================================================
// *****FILL LINE
// ================================================================

void MSI_SMPCache::fillLine(uint64_t addr, uint32_t msi_state, linedata_t val=linedata_t()){

  //this gets the state of whatever line this address maps to 
  MSI_SMPCacheState *st = (MSI_SMPCacheState *)cache->findLine2Replace(addr); 

  if(enable_prints) printf("%d::::PULKIT entering fillline:: addr=%lx\n",this->getCPUId(),addr);

  if(st==0){
    /*No state*/ exit(1);
    return;
  }
  if ((!st->islineInvalid) && parent!=NULL){
  	parent->writeLine(cache->calcAddr4Tag(st->getTag()),st->getData()); // Pushing the evicted or replaced line to the next level
  	numReplacements++;
  }
  /*Set the tags to the tags for the newly cached block*/
  st->setTag(cache->calcTag(addr));
  st->setData(val);

  /*Set the state of the block to the msi_state passed in*/
  st->changeStateTo((MSIState_t)msi_state);
  if(enable_prints) printf("%d::::HENRY value set in fillline:: addr=%lx, val=%x\n",this->getCPUId(),addr, st->getData(cache->calcOffset(addr)));
  
  return;
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
        return MSI_SMPCache::RemoteReadService(false,true,otherState->getData(),true); // no need to check for MSB, as it is in modified state

      /*Other cache has recently read the line*/
      }else if(otherState->getState() == MSI_SHARED && otherState->isValid()){  
        
        /*Return a Remote Read Service indicating that 
         *1)The line was shared (the true param)
         *2)The line was provided by otherCache 
        */
	      return MSI_SMPCache::RemoteReadService(true,true,otherState->getData());

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
				// printf("last level reached\n");
			 	// exit(1);
		 	}
		 	else 
				ld = parent->readLine(addr);
    }    
    
    fillLine(addr, MSI_SHARED, ld);
  }
  else{
  	numReadHits++; 
		ld = st->getData();
  }
  
  return ld;

}
  
// ================================================================
// *****WRITE LINE
// ================================================================
void MSI_SMPCache::writeLine(uint64_t addr, linedata_t ld){ // only used for evicted lines due to replacement
  if(enable_prints) printf("%d::::PULKIT entering writeline:: addr=%lx\n",this->getCPUId(),addr);
	MSI_SMPCacheState *st = (MSI_SMPCacheState *)cache->findLine(addr);  
	numWritebacksReceived++;

	if(!st || (st && !(st->isValid())) ){	//Write Miss
		// printf("inclusiveness not maintained\n");
	 	// exit(1);
    fillLine(addr,MSI_MODIFIED,ld);
	}
	
  else{ //Write Hit
	  if(enable_prints) printf("%d::::PULKIT entering writeline1:: addr=%lx\n",this->getCPUId(),addr);
   	numWriteHits++; 
		st->setData(ld);
  }
  
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
    	if (parent!=NULL) {
        ld = parent->readLine(addr);
      } 
      else {
        printf("%d::::NULL PARENT SEEN\n",this->getCPUId());
      } 
    }
    
    if(st){  // stale data present, compare with the coherent data for T/F sharing stats
	    
      uint32_t lcd, rcd; //local cache data, remote cache data
			lcd = st->getData(cache->calcOffset(addr)); //NEEDS CHECK
			rcd = ld.data[cache->calcOffset(addr)];

      // using unit64 for bound to avoid rollover on uint32 values
      uint64_t lowBound = (uint64_t)( (1 - APPROX_THRESHOLD) * rcd );
      uint64_t highBound = (uint64_t)( (1 + APPROX_THRESHOLD) * rcd );
      
      if(enable_prints) printf("%d::::PULKIT TF STATS readline:: READING LINE addr=%lx, offset:%d\n",this->getCPUId(),addr,cache->calcOffset(addr));
 	    
      if (lcd == rcd) {
        if (rrs.dirtyBit) {
          numFalseSharingSilentStore++;
        }
        else {
          numFalseSharing++;
        }
		    numCorrectSpeculations++;
 	    	if(enable_prints) printf("False Sharing++");
      }
      else if ( (lcd >= lowBound) && (lcd <= highBound) ) {
        printf("Low Bound: %ld, Data: %d High Bound: %ld\n", lowBound, lcd, highBound);
        numCorrectApproxSpeculations++;
      }
      else {
      	numTrueSharing++;
        numIncorrectSpeculations++;
      	if(enable_prints) printf("True Sharing++");}

      
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
MSI_SMPCache::InvalidateReply  MSI_SMPCache::writeRemoteAction(uint64_t addr, uint32_t val = INT_NAN){
    
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

      /*
        CD-W. Update on every write if any sharers exist (even if invalid).
      */
      if (otherState && ENABLE_CD_W) {
        otherState->setData(val, cache->calcOffset(addr));
      }

      /*if it is cached by otherCache*/
      if(otherState && otherState->isValid()){

          /*The reply contains data, so "empty" is false*/
          reply.empty = false;
          reply.linedata = otherState->getData();

          /*
            CD-IA. Use invalidation piggyback to update all invalid blocks
          */
          if (ENABLE_CD_IA) {
            otherState->setData(val, cache->calcOffset(addr));
          }

          /*Invalidate the line, because we're writing*/
          otherState->invalidate();
      }
    }
    
    return reply;
}



// ================================================================
// *****WRITE WORD (only to be called by MCS.cpp)
// ================================================================
void MSI_SMPCache::writeWord(uint32_t wrPC, uint64_t addr, uint32_t val=INT_NAN){

  /*Find the line to which this address maps*/ 
  MSI_SMPCacheState * st = (MSI_SMPCacheState *)cache->findLine(addr);    

  if(!st || (st && !(st->isValid())) ){ 
    numWriteMisses++;

    if(st){ // We're writing to an invalid line
      numWriteOnInvalidMisses++;
    }
		// Let the other caches snoop this write access and update their state accordingly.  This action is effectively putting the write on the bus.
    MSI_SMPCache::InvalidateReply inv_ack = writeRemoteAction(addr, val);
    numInvalidatesSent++;
    if (inv_ack.empty) {
    	inv_ack.linedata = 	parent->readLine(addr);
    }
		inv_ack.linedata.data[cache->calcOffset(addr)] = val;
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
    writeRemoteAction(addr, val); 
    numInvalidatesSent++;

    uint32_t prevData = st->getData(cache->calcOffset(addr));
    if (prevData == val) {
      numSilentStores++;
    }
    /*Change the state of the line to Modified to reflect the write*/
    st->changeStateTo(MSI_MODIFIED);
    st->setData(val,cache->calcOffset(addr));
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

    if (ENABLE_CD_W) {
      writeRemoteAction(addr, val);
    }
    
    return;
  }

}

char *MSI_SMPCache::Identify(){
  return (char *)"MSI Cache Coherence";
}

MSI_SMPCache::~MSI_SMPCache(){

}

extern "C" SMPCache *Create(int num, std::vector<SMPCache*> *same, SMPCache* next, std::vector<SMPCache*> *prev, int csize, int casso, int bs, int addrble, const char *repl, bool skw){
//cvec->same, main->next
  return new MSI_SMPCache(num,same,next,prev,csize,casso,bs,addrble,repl,skw);

}
