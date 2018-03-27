#include "MultiCacheSim.h"

MultiCacheSim::MultiCacheSim(FILE *cachestats, int size, int assoc, int bsize, CacheFactory c){

  cacheFactory = c;
  CacheStats = cachestats;
  num_caches = 0;
  cache_size = size;
  cache_assoc = assoc;
  cache_bsize = bsize; 

  #ifndef PIN
  pthread_mutex_init(&allCachesLock, NULL);
  #else
  PIN_InitLock(&allCachesLock);
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
    std::vector<SMPCache *>::iterator cacheIter = allCaches.begin();
    std::vector<SMPCache *>::iterator cacheEndIter = allCaches.end();
    for(; cacheIter != cacheEndIter; cacheIter++){
      if((*cacheIter)->CPUId == CPUid){
        return (*cacheIter);
      }
    }
    return NULL;
} 
  
void MultiCacheSim::dumpStatsForAllCaches(bool concise){
   
    std::vector<SMPCache *>::iterator cacheIter = allCaches.begin();
    std::vector<SMPCache *>::iterator cacheEndIter = allCaches.end();
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
    pthread_mutex_lock(&allCachesLock);
    #else
    PIN_GetLock(&allCachesLock,1); 
    #endif

    SMPCache * newcache;
    newcache = this->cacheFactory(num_caches++, &allCaches, llc_memory, cache_size, cache_assoc, cache_bsize, 1, "LRU", false);
    allCaches.push_back(newcache);


    #ifndef PIN
    pthread_mutex_unlock(&allCachesLock);
    #else
    PIN_ReleaseLock(&allCachesLock); 
    #endif
}


void MultiCacheSim::createLLC() {

  #ifndef PIN
  pthread_mutex_lock(&LLCLock);
  #else
  PIN_GetLock(&LLCLock,1); 
  #endif

  SMPCache * newcache;
  newcache = this->cacheFactory(0, &llc, main_memory, cache_size*128, cache_assoc*64, cache_bsize, 1, "LRU", false);
  llc.push_back(newcache);
  llc_memory = newcache;

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
  newcache = this->cacheFactory(0, &main, NULL, cache_size*128, cache_assoc*64, cache_bsize, 1, "LRU", false);
  main.push_back(newcache);
  main_memory = newcache;

  #ifndef PIN
  pthread_mutex_unlock(&mainLock);
  #else
  PIN_ReleaseLock(&mainLock); 
  #endif
}

// this is for SCL Caches (MSHRs) to link actual Caches with SCL.
void MultiCacheSim::createNewSCL(SMPCache *attachCache){

    #ifndef PIN
    pthread_mutex_lock(&allCachesLock);
    #else
    PIN_GetLock(&allCachesLock,1); 
    #endif

    SMPCache * newcache;
    newcache = this->cacheFactory(num_caches++, &allCaches, NULL, cache_size, cache_assoc, cache_bsize, 1, "LRU", false);
    newcache->linkedCache = attachCache -> cache;
    printf("SCL MSHR %d linked to Cache %d\n", newcache->getCPUId(), attachCache->getCPUId());

    allCaches.push_back(newcache);


    #ifndef PIN
    pthread_mutex_unlock(&allCachesLock);
    #else
    PIN_ReleaseLock(&allCachesLock); 
    #endif
}

uint32_t MultiCacheSim::readLine(unsigned long tid, unsigned long rdPC, uint64_t addr){
  uint32_t val;
    #ifndef PIN
    pthread_mutex_lock(&allCachesLock);
    #else
    PIN_GetLock(&allCachesLock,1); 
    #endif


    SMPCache * cacheToRead = findCacheByCPUId(tidToCPUId(tid));
    if(!cacheToRead){
      return 0;
    }
    val = cacheToRead->readLine(rdPC,addr);
    //printf ("addr = %lx, val = %lx\n", addr, val);


    #ifndef PIN
    pthread_mutex_unlock(&allCachesLock);
    #else
    PIN_ReleaseLock(&allCachesLock); 
    #endif
    return val;
}
  
void MultiCacheSim::writeLine(unsigned long tid, unsigned long wrPC, uint64_t addr, uint32_t val = 0){
    #ifndef PIN
    pthread_mutex_lock(&allCachesLock);
    #else
    PIN_GetLock(&allCachesLock,1); 
    #endif


    SMPCache * cacheToWrite = findCacheByCPUId(tidToCPUId(tid));
    if(!cacheToWrite){
      return;
    }
    cacheToWrite->writeLine(wrPC,addr, val);


    #ifndef PIN
    pthread_mutex_unlock(&allCachesLock);
    #else
    PIN_ReleaseLock(&allCachesLock); 
    #endif
    return;
}


// Speculative readLine for SCL - HENRY
void MultiCacheSim::readLineSpeculative(unsigned long tid, unsigned long rdPC, uint64_t addr){
    #ifndef PIN
    pthread_mutex_lock(&allCachesLock);
    #else
    PIN_GetLock(&allCachesLock,1); 
    #endif


    SMPCache * cacheToRead = findCacheByCPUId(tidToCPUId(tid));
    if(!cacheToRead){
      return;
    }
    cacheToRead->readLine(rdPC,addr);


    #ifndef PIN
    pthread_mutex_unlock(&allCachesLock);
    #else
    PIN_ReleaseLock(&allCachesLock); 
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
    std::vector<SMPCache *>::iterator cacheIter = allCaches.begin();
    std::vector<SMPCache *>::iterator cacheEndIter = allCaches.end();
    for(; cacheIter != cacheEndIter; cacheIter++){
      delete (*cacheIter);
    }

    cacheIter = main.begin();
    cacheEndIter = main.end();
    for(; cacheIter != cacheEndIter; cacheIter++){
      delete (*cacheIter);
    }
}
