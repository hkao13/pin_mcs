#include "SCL_Read_SMPCache.h"

bool enable_prints=1;

SCL_Read_SMPCache::SCL_Read_SMPCache(int cpuid, 
                           std::vector<SMPCache * > * cacheVector,
                           int csize, 
                           int cassoc, 
                           int cbsize, 
                           int caddressable, 
                           const char * repPol, 
                           bool cskew) : 
                             SMPCache(cpuid,cacheVector){
  
  fprintf(stderr,"Making a SCL_Read cache with cpuid %d\n",cpuid);
  CacheGeneric<SCL_Read_SMPCacheState> *c = 
    CacheGeneric<SCL_Read_SMPCacheState>::create(csize, 
                                            cassoc, 
                                            cbsize, 
                                            caddressable, 
                                            repPol, 
                                            cskew);
  cache = (CacheGeneric<StateGeneric<> >*)c; 

}

void SCL_Read_SMPCache::fillLine(uint32_t addr, uint32_t msi_state){

  return;
}

// Overloaded fillLine to handle values - HENRY
void SCL_Read_SMPCache::fillLine(uint32_t addr, uint32_t msi_state, uint32_t val){

  return;
}

void SCL_Read_SMPCache::readLine(uint32_t rdPC, uint32_t addr){

  return;
}


// Overloaded readLine to account for value stores - HENRY
void SCL_Read_SMPCache::readLine(uint32_t rdPC, uint32_t addr, uint32_t val){
  
  return;
}


void SCL_Read_SMPCache::writeLine(uint32_t wrPC, uint32_t addr){
  /*This method implements actions taken when instruction wrPC
   *writes to memory location addr*/

  /*SCL Read Component, DO nothing - HENRY*/
  return;
}

// Overloaded writeLine to handle write values - HENRY
void SCL_Read_SMPCache::writeLine(uint32_t wrPC, uint32_t addr, uint32_t val){
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

extern "C" SMPCache *Create(int num, std::vector<SMPCache*> *cvec, int csize, int casso, int bs, int addrble, const char *repl, bool skw){

  return new SCL_Read_SMPCache(num,cvec,csize,casso,bs,addrble,repl,skw);

}
