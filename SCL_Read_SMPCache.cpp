#include "SCL_Read_SMPCache.h"

//bool enable_prints=0;

SCL_Read_SMPCache::SCL_Read_SMPCache(int cpuid, 
                           std::vector<SMPCache * > * cacheVector,
			   SMPCache * main,
                           int csize, 
                           int cassoc, 
                           int cbsize, 
                           int caddressable, 
                           const char * repPol, 
                           bool cskew) : 
                             SMPCache(cpuid,cacheVector,main){
  
  fprintf(stderr,"Making a SCL_Read MSHR with cpuid %d\n",cpuid);
  CacheGeneric<SCL_Read_SMPCacheState> *c = 
    CacheGeneric<SCL_Read_SMPCacheState>::create(csize, 
                                            cassoc, 
                                            cbsize, 
                                            caddressable, 
                                            repPol, 
                                            cskew);
  cache = (CacheGeneric<StateGeneric<> >*)c; 

}

void SCL_Read_SMPCache::fillLine(uint64_t addr, uint32_t msi_state, linedata_t val=linedata_t()){

  return;
}

// Speculative readLine
uint32_t SCL_Read_SMPCache::readLine(uint32_t rdPC, uint64_t addr){

    if (linkedCache) {

      MSI_SMPCacheState * st = (MSI_SMPCacheState *)linkedCache -> findLine(addr);
 
      if(!st){ 
        // Line not present in cache so do nothing
        return 0;
      }

      else if( st && !(st->isValid()) ) { 
        // Here the line is in an invalid state, do something.
        if (enable_prints) printf("HENRY peek at addr=%lx, state=%d\n", addr, (int)st -> getState());
      }

      else {
        // Here the line is in a valid state so do nothing.
        //if (enable_prints) printf("HENRY peek at addr=%lx, state=%d\n", addr, (int)st -> getState());
      }

    }

  return 0;
}


void SCL_Read_SMPCache::writeLine(uint32_t wrPC, uint64_t addr, uint32_t val=0){
  /*This method implements actions taken when instruction wrPC
   *writes to memory location addr*/

  /*SCL Read Component, DO nothing - HENRY*/
  return;
}



char *SCL_Read_SMPCache::Identify(){
  return (char *)"SCL_Read Cache Coherence";
}

SCL_Read_SMPCache::~SCL_Read_SMPCache(){

}

extern "C" SMPCache *Create(int num, std::vector<SMPCache*> *cvec, SMPCache *main, int csize, int casso, int bs, int addrble, const char *repl, bool skw){

  return new SCL_Read_SMPCache(num,cvec,main,csize,casso,bs,addrble,repl,skw);

}
