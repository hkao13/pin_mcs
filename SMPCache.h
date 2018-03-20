#ifndef __SMPCACHE_H_
#define __SMPCACHE_H_
#include "CacheCore.h"
#include <vector>


class SMPCache{

public:
  unsigned long CPUId;
  
  //The actual SESC cache object
  CacheGeneric<StateGeneric<> > *cache, *linkedCache; // one for SCL -HENRY

  //A vector of all the caches in the multicachesim
  std::vector<SMPCache * > *allCaches;
  
  SMPCache *main_memory;
  
  //Stats about the events the cache saw during execution
  int numReadHits;
  int numReadMisses;

  int numReadOnInvalidMisses;
  int numReadRequestsSent;
  int numReadMissesServicedByOthers;
  int numReadMissesServicedByShared;
  int numReadMissesServicedByModified;

  int numWriteHits;
  int numWriteMisses;

  int numWriteOnSharedMisses;
  int numWriteOnInvalidMisses;
  int numInvalidatesSent;

  /* New stats for true/false sharing for SCL */
  int numFalseSharing;
  int numTrueSharing;
  
  SMPCache(int cpuid, std::vector<SMPCache * > * cacheVector, SMPCache *main);
  virtual ~SMPCache(){}
  
  int getCPUId();
  std::vector<SMPCache * > *getCacheVector();
  //Readline performs a read, and uses readRemoteAction to 
  //check for data in other caches
  virtual  uint32_t readLine(uint32_t rdPC, uint64_t addr)=0;

  //Writeline performs a write, and uses writeRemoteAction
  //to check for data in other caches
  virtual void writeLine(uint32_t wrPC, uint64_t addr, uint32_t val)=0;
 
  //Fill line touches cache state, bringing addr's block in, and setting its state to mesi_state 
  virtual void fillLine(uint64_t addr, uint32_t mesi_state, linedata_t val) = 0;

  virtual char *Identify() = 0;

  //Dump the stats for this cache to outFile
  virtual void dumpStatsToFile(FILE* outFile);
  virtual void conciseDumpStatsToFile(FILE* outFile);
  
  int getStateAsInt(uint64_t addr);

};

typedef SMPCache *(*CacheFactory)(int, std::vector<SMPCache*> *, SMPCache*, int, int, int, int, const char *, bool);
#endif
