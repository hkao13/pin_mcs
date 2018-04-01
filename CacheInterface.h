#ifndef _CACHEINTERFACE_H_
#define _CACHEINTERFACE_H_
class CacheInterface{
public:
  virtual unsigned int readLine(unsigned long tid, unsigned long rdPC, unsigned long addr) = 0;
  virtual void writeLine(unsigned long tid, unsigned long rdPC, unsigned long addr, unsigned int val) = 0;
  virtual void dumpStatsForPrivateCaches(bool concise) = 0;
};
#endif
