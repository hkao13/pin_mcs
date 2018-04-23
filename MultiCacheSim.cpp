#include "MultiCacheSim.h"
#include "math.h"

static inline int numbits(int x) {
  if (x==0) return 1;
  else {
    int ii;
    for (ii=0;x!=0; ii++,x/=2);
    return ii;
  }
}

MultiCacheSim::MultiCacheSim(FILE *cachestats, int size, int assoc, int bsize, CacheFactory c){

  cacheFactory = c;
  CacheStats = cachestats;
  num_caches = 0;
  cache_size = size;
  cache_assoc = assoc;
  cache_bsize = bsize; 

  #ifndef PIN
  pthread_mutex_init(&privateCachesLock, NULL);
  #else
  PIN_InitLock(&privateCachesLock);
  #endif

  #ifndef PIN
  pthread_mutex_init(&mainLock, NULL);
  #else
  PIN_InitLock(&mainLock);
  #endif

  #ifndef PIN
  pthread_mutex_init(&LLCLock, NULL);
  #else
  PIN_InitLock(&LLCLock);
  #endif

}

SMPCache *MultiCacheSim::findCacheByCPUId(unsigned int CPUid){
    std::vector<SMPCache *>::iterator cacheIter = privateCaches.begin();
    std::vector<SMPCache *>::iterator cacheEndIter = privateCaches.end();
    for(; cacheIter != cacheEndIter; cacheIter++){
      if((*cacheIter)->CPUId == CPUid){
        return (*cacheIter);
      }
    }
    return NULL;
} 
  
void MultiCacheSim::dumpStatsForPrivateCaches(bool concise){
   
    std::vector<SMPCache *>::iterator cacheIter = privateCaches.begin();
    std::vector<SMPCache *>::iterator cacheEndIter = privateCaches.end();
    for(; cacheIter != cacheEndIter; cacheIter++){
      if(!concise){
        (*cacheIter)->dumpStatsToFile(CacheStats);
      }else{

    fprintf(CacheStats,"CPUId, numReadHits, numReadMisses, numReadOnInvalidMisses, numReadRequestsSent, numReadMissesServicedByOthers, numReadMissesServicedByShared, numReadMissesServicedByModified, numWriteHits, numWriteMisses, numWriteOnSharedMisses, numWriteOnInvalidMisses, numInvalidatesSent\n");

        (*cacheIter)->conciseDumpStatsToFile(CacheStats);
      }
    }
}

void MultiCacheSim::dumpStatsForLLC(bool concise){
   
    std::vector<SMPCache *>::iterator cacheIter = llc.begin();
    std::vector<SMPCache *>::iterator cacheEndIter = llc.end();
    printf("--- LLC ---\n");
    for(; cacheIter != cacheEndIter; cacheIter++){
      if(!concise){
        (*cacheIter)->dumpStatsToFile(CacheStats);
      }else{

    fprintf(CacheStats,"CPUId, numReadHits, numReadMisses, numReadOnInvalidMisses, numReadRequestsSent, numReadMissesServicedByOthers, numReadMissesServicedByShared, numReadMissesServicedByModified, numWriteHits, numWriteMisses, numWriteOnSharedMisses, numWriteOnInvalidMisses, numInvalidatesSent\n");

        (*cacheIter)->conciseDumpStatsToFile(CacheStats);
      }
    }
}

void MultiCacheSim::dumpStatsForMain(bool concise){
   
    std::vector<SMPCache *>::iterator cacheIter = main.begin();
    std::vector<SMPCache *>::iterator cacheEndIter = main.end();
    printf("--- MAIN MEMORY ---\n");
    for(; cacheIter != cacheEndIter; cacheIter++){
      if(!concise){
        (*cacheIter)->dumpStatsToFile(CacheStats);
      }else{

    fprintf(CacheStats,"CPUId, numReadHits, numReadMisses, numReadOnInvalidMisses, numReadRequestsSent, numReadMissesServicedByOthers, numReadMissesServicedByShared, numReadMissesServicedByModified, numWriteHits, numWriteMisses, numWriteOnSharedMisses, numWriteOnInvalidMisses, numInvalidatesSent\n");

        (*cacheIter)->conciseDumpStatsToFile(CacheStats);
      }
    }
}

void MultiCacheSim::createNewCache(){

    #ifndef PIN
    pthread_mutex_lock(&privateCachesLock);
    #else
    PIN_GetLock(&privateCachesLock,1); 
    #endif

    SMPCache * newcache;
    newcache = this->cacheFactory(num_caches++, &privateCaches, llc_memory, NULL, false /*isxor*/, cache_size, cache_assoc, cache_bsize, 1, "LRU", false);
    privateCaches.push_back(newcache);


    #ifndef PIN
    pthread_mutex_unlock(&privateCachesLock);
    #else
    PIN_ReleaseLock(&privateCachesLock); 
    #endif
}

void MultiCacheSim::createLLC() {

  #ifndef PIN
  pthread_mutex_lock(&LLCLock);
  #else
  PIN_GetLock(&LLCLock,1); 
  #endif

  SMPCache * newcache;
//   newcache = this->cacheFactory(16, &llc, main_memory, &privateCaches, true /*isxor*/, pow(2,numbits(num_caches))*cache_size*4, pow(2,numbits(num_caches))*cache_assoc*4, cache_bsize, 1, "RANDOM", false);
  newcache = this->cacheFactory(16, &llc, main_memory, &privateCaches, true /*isxor*/, cache_size*4, cache_assoc*2, cache_bsize, 1, "RANDOM", false);
  llc.push_back(newcache);
  llc_memory = newcache;
  
  std::vector<SMPCache * >::iterator cacheIter;
  std::vector<SMPCache * >::iterator lastCacheIter;
  for(cacheIter = privateCaches.begin(), 
      lastCacheIter = privateCaches.end(); 
      cacheIter != lastCacheIter; 
      cacheIter++){
      MSI_SMPCache *child = (MSI_SMPCache*)*cacheIter;
      child->parent = newcache;
  }
  #ifndef PIN
  pthread_mutex_unlock(&LLCLock);
  #else
  PIN_ReleaseLock(&LLCLock); 
  #endif

}

void MultiCacheSim::createMain(){

  #ifndef PIN
  pthread_mutex_lock(&mainLock);
  #else
  PIN_GetLock(&mainLock,1); 
  #endif

  SMPCache * newcache;
  newcache = this->cacheFactory(17, &main, NULL, &llc, false /*isxor*/, cache_size*1024, cache_assoc*1024, cache_bsize, 1, "LRU", false);
  main.push_back(newcache);
  main_memory = newcache;

  std::vector<SMPCache * >::iterator cacheIter;
  std::vector<SMPCache * >::iterator lastCacheIter;
  for(cacheIter = llc.begin(), 
      lastCacheIter = llc.end(); 
      cacheIter != lastCacheIter; 
      cacheIter++){
      MSI_SMPCache *child = (MSI_SMPCache*)*cacheIter;
      child->parent = newcache;
  }

  #ifndef PIN
  pthread_mutex_unlock(&mainLock);
  #else
  PIN_ReleaseLock(&mainLock); 
  #endif
}

uint32_t MultiCacheSim::readLine(unsigned long tid, unsigned long rdPC, uint64_t addr){
  uint32_t val;
    #ifndef PIN
    pthread_mutex_lock(&privateCachesLock);
    #else
    PIN_GetLock(&privateCachesLock,1); 
    #endif


    SMPCache * cacheToRead = findCacheByCPUId(tidToCPUId(tid));
    if(!cacheToRead){
      return 0;
    }
    val = cacheToRead->readWord(rdPC,addr);
    //printf ("addr = %lx, val = %lx\n", addr, val);


    #ifndef PIN
    pthread_mutex_unlock(&privateCachesLock);
    #else
    PIN_ReleaseLock(&privateCachesLock); 
    #endif
    return val;
}
  
void MultiCacheSim::writeLine(unsigned long tid, unsigned long wrPC, uint64_t addr, uint32_t val = 0){
    #ifndef PIN
    pthread_mutex_lock(&privateCachesLock);
    #else
    PIN_GetLock(&privateCachesLock,1); 
    #endif


    SMPCache * cacheToWrite = findCacheByCPUId(tidToCPUId(tid));
    if(!cacheToWrite){
      return;
    }
    cacheToWrite->writeWord(wrPC,addr, val);


    #ifndef PIN
    pthread_mutex_unlock(&privateCachesLock);
    #else
    PIN_ReleaseLock(&privateCachesLock); 
    #endif
    return;
}


int MultiCacheSim::getStateAsInt(unsigned long tid, uint64_t addr){

  SMPCache * cacheToWrite = findCacheByCPUId(tidToCPUId(tid));
  if(!cacheToWrite){
    return -1;
  }
  return cacheToWrite->getStateAsInt(addr);

}

int MultiCacheSim::tidToCPUId(int tid){
    //simple for now, perhaps we want to be fancier
    return tid % num_caches; 
}

char *MultiCacheSim::Identify(){
  SMPCache *c = findCacheByCPUId(0);
  if(c != NULL){
    return c->Identify();
  }
  return 0;
}
  
MultiCacheSim::~MultiCacheSim(){
    std::vector<SMPCache *>::iterator cacheIter = privateCaches.begin();
    std::vector<SMPCache *>::iterator cacheEndIter = privateCaches.end();
    for(; cacheIter != cacheEndIter; cacheIter++){
      delete (*cacheIter);
    }

    cacheIter = main.begin();
    cacheEndIter = main.end();
    for(; cacheIter != cacheEndIter; cacheIter++){
      delete (*cacheIter);
    }
}
