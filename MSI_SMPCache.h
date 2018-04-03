#include "CacheCore.h"
#include "SMPCache.h"
#include "MSI_SMPCacheState.h"
#include <vector>

class MSI_SMPCache : public SMPCache{

public:
  /*First we define a couple of helper classes that 
   * carry data between methods in our main class*/
  class RemoteReadService{
  public:
    bool isShared;
    bool providedData;
    linedata_t linedata;
    bool dirtyBit;	//DIRTY_BIT
  
    RemoteReadService(bool shrd, bool prov, linedata_t data=linedata_t(), bool dirty=false){	//DIRTY_BIT
//    RemoteReadService(bool shrd, bool prov, linedata_t data=linedata_t()){
      isShared = shrd;
      providedData = prov;
      linedata = data;
      dirtyBit = dirty;	//DIRTY_BIT
    }
    
  };
  
  class InvalidateReply{
  /*This class isn't used, but i left it here so you
   * could add to it if you need to communicate
   * between caches in Invalidate Replies*/
  public:
    uint32_t empty;
    linedata_t linedata;
  
    InvalidateReply(bool EMPTY, linedata_t data=linedata_t()){
      empty = EMPTY;
      linedata = data;
    }
  
  };

  //FIELDS
  //This cache's ID
  int CPUId;


  //METHODS
  //Constructor
  MSI_SMPCache(int cpuid, 
               std::vector<SMPCache * > * same, //siblings
               SMPCache * next, 								//parent
               std::vector<SMPCache * > * prev,	//children
               int csize, 
               int cassoc, 
               int cbsize, 
               int caddressable, 
               const char * repPol, 
               bool cskew);

  //Readline performs a read, and uses readRemoteAction to 
  //check for data in other caches
  
  virtual uint32_t readWord(uint32_t rdPC, uint64_t addr);//SMPCache Interface Function
  virtual linedata_t readLine(uint64_t addr);
  virtual MSI_SMPCache::RemoteReadService readRemoteAction(uint64_t addr);
	virtual void writeLine(uint64_t addr, linedata_t ld);
  //Writeline performs a write, and uses writeRemoteAction
  //to check for data in other caches
  virtual void writeWord(uint32_t wrPC, uint64_t addr, uint32_t val);//SMPCache Interface Function
  virtual MSI_SMPCache::InvalidateReply writeRemoteAction(uint64_t addr, uint32_t val);
 
  //Fill line touches cache state, bringing addr's block in, and setting its state to msi_state 
  virtual void fillLine(uint64_t addr, uint32_t msi_state, linedata_t val);//SMPCache Interface Function

  virtual char *Identify();
 
  //Dump the stats for this cache to outFile
  //virtual void dumpStatsToFile(FILE* outFile);

  //Destructor
  ~MSI_SMPCache();
};


