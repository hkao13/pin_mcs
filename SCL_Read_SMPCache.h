#include "CacheCore.h"
#include "SMPCache.h"
#include "SCL_Read_SMPCacheState.h"
#include "MSI_SMPCacheState.h"
#include <vector>

class SCL_Read_SMPCache : public SMPCache{

public:

  //FIELDS
  //This cache's ID
  int CPUId;

  //METHODS
  //Constructor
  SCL_Read_SMPCache(int cpuid, 
               std::vector<SMPCache * > * cacheVector, 
               int csize, 
               int cassoc, 
               int cbsize, 
               int caddressable, 
               const char * repPol, 
               bool cskew);

  //Readline performs a read, and uses readRemoteAction to 
  //check for data in other caches
  virtual void readLine(uint32_t rdPC, uint32_t addr);//SMPCache Interface Function
  // Overloaded read function with value
  virtual void readLine(uint32_t rdPC, uint32_t addr, uint32_t val);//SMPCache Interface Function

  //Writeline performs a write, and uses writeRemoteAction
  //to check for data in other caches
  virtual void writeLine(uint32_t wrPC, uint32_t addr);//SMPCache Interface Function
  // Overloaded write function with value
  virtual void writeLine(uint32_t wrPC, uint32_t addr, uint32_t val);//SMPCache Interface Function
 
  //Fill line touches cache state, bringing addr's block in, and setting its state to msi_state 
  virtual void fillLine(uint32_t addr, uint32_t msi_state);//SMPCache Interface Function
  // Overload the fillLine to handle values
  virtual void fillLine(uint32_t addr, uint32_t msi_state, uint32_t val);//SMPCache Interface Function

  virtual char *Identify();
 
  //Dump the stats for this cache to outFile
  //virtual void dumpStatsToFile(FILE* outFile);

  //Destructor
  ~SCL_Read_SMPCache();
};