#include "pin.H"

#include <signal.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <string.h>
#include <dlfcn.h>

#include "MultiCacheSim.h"

std::vector<MultiCacheSim *> Caches;
#define isStack(addr) (addr<=0x7FFFFFFFFFFF && addr>=0x700000000000)
MultiCacheSim *ReferenceProtocol;
PIN_LOCK globalLock;

bool stopOnError = false;
bool printOnError = false;
bool useRef = false;
bool enable_prints = false;
bool henry_debug = true;

bool do_instrumentation = false;

long int writecount;
ADDRINT writeaddr; THREADID writetid; ADDRINT writeinst;
bool useSCL = false;
std::vector<MultiCacheSim *> SCL_Caches;

KNOB<bool> KnobStopOnError(KNOB_MODE_WRITEONCE, "pintool",
			   "stopOnProtoBug", "false", "Stop the Simulation when a deviation is detected between the test protocol and the reference");//default cache is verbose 

KNOB<bool> KnobPrintOnError(KNOB_MODE_WRITEONCE, "pintool",
			   "printOnProtoBug", "false", "Print a debugging message when a deviation is detected between the test protocol and the reference");//default cache is verbose 

KNOB<bool> KnobUseReference(KNOB_MODE_WRITEONCE, "pintool",
			   "useref", "false", "Use a reference protocol to compare running protocol states with (default = false)");//default cache is verbose 

KNOB<bool> KnobConcise(KNOB_MODE_WRITEONCE, "pintool",
			   "concise", "false", "Print output concisely");//default cache is verbose

KNOB<bool> KnobUseSCL(KNOB_MODE_WRITEONCE, "pintool",
         "usescl", "false", "Use the SCL"); // SCL Knob

KNOB<unsigned int> KnobCacheSize(KNOB_MODE_WRITEONCE, "pintool",
			   "csize", "65536", "Cache Size");//default cache is 64KB

KNOB<unsigned int> KnobBlockSize(KNOB_MODE_WRITEONCE, "pintool",
			   "bsize", "64", "Block Size");//default block is 64B

KNOB<unsigned int> KnobAssoc(KNOB_MODE_WRITEONCE, "pintool",
			   "assoc", "2", "Associativity");//default associativity is 2-way

KNOB<unsigned int> KnobNumCaches(KNOB_MODE_WRITEONCE, "pintool",
			   "numcaches", "1", "Number of Caches to Simulate");

KNOB<string> KnobProtocol(KNOB_MODE_WRITEONCE, "pintool",
			   "protos", "obj-intel64/MSI_SMPCache.so", "Cache Coherence Protocol Modules To Simulate");

KNOB<string> KnobReference(KNOB_MODE_WRITEONCE, "pintool",
			   "reference", "obj-intel64/MESI_SMPCache.so", "Reference Protocol that is compared to test Protocols for Correctness");

KNOB<string> KnobSCL(KNOB_MODE_WRITEONCE, "pintool",
         "scl", "obj-intel64/SCL_Read_SMPCache.so", "Speculative Cache Lookup file");

#define MAX_NTHREADS 64
unsigned long instrumentationStatus[MAX_NTHREADS];

enum MemOpType { MemRead = 0, MemWrite = 1 };

INT32 usage()
{
    cerr << "MultiCacheSim -- A Multiprocessor cache simulator with a pin frontend";
    cerr << KNOB_BASE::StringKnobSummary();
    cerr << endl;
    return -1;
}


VOID TurnInstrumentationOn(ADDRINT tid){
  instrumentationStatus[PIN_ThreadId()] = true; 
}

VOID TurnInstrumentationOff(ADDRINT tid){
  instrumentationStatus[PIN_ThreadId()] = false; 
}

VOID ToggleInstrumentation()
{
  do_instrumentation = !do_instrumentation;
}

VOID instrumentRoutine(RTN rtn, VOID *v){
    
  if(strstr(RTN_Name(rtn).c_str(),"INSTRUMENT_OFF")){
    RTN_Open(rtn);
    RTN_InsertCall(rtn, 
                   IPOINT_BEFORE, 
                   (AFUNPTR)TurnInstrumentationOff, 
                   IARG_THREAD_ID,
                   IARG_END);
    RTN_Close(rtn);
  }
   
  
  if(strstr(RTN_Name(rtn).c_str(),"INSTRUMENT_ON")){
    RTN_Open(rtn);
    RTN_InsertCall(rtn, 
                   IPOINT_BEFORE, 
                   (AFUNPTR)TurnInstrumentationOn, 
                   IARG_THREAD_ID,
                   IARG_END);
    RTN_Close(rtn);
  }

}

VOID instrumentImage(IMG img, VOID *v)
{

  RTN rtn = RTN_FindByName(img, "start_instrumentation");

  if(RTN_Valid(rtn)) {
    RTN_Open(rtn);

    RTN_InsertCall(
        rtn,
        IPOINT_BEFORE,
        AFUNPTR(ToggleInstrumentation),
        IARG_END
        );

    RTN_Close(rtn);
  }

}

void Read(THREADID tid, ADDRINT addr, ADDRINT inst){

  if (!instrumentationStatus[PIN_ThreadId()] || isStack(addr)) { // Only do instrumentation if do_instrumentation is true.
    return;
  }

  PIN_GetLock(&globalLock, 1);

  if(useRef){
    ReferenceProtocol->readLine(tid,inst,addr);
  }
  std::vector<MultiCacheSim *>::iterator i,e;

  /* Speculative load */
  if (useSCL) {

    for(i = SCL_Caches.begin(), e = SCL_Caches.end(); i != e; i++){
      (*i) -> readLineSpeculative(tid, inst, addr);
    }
    
  }

  // Get the value of the memory address, uncomment below to see.
  ADDRINT * addr_ptr = (ADDRINT*)addr;
  uint32_t value1, value2;
  PIN_SafeCopy(&value1, addr_ptr, sizeof(ADDRINT));
  if (enable_prints) printf("---------------------------------------------------------------Read: ADDR, VAL: %lx, %x\n", addr, value1);

  if (henry_debug) {
    printf("CPU %d -- READ:\tAddress:%lx,\tValue:%x\n", tid, addr, value1);
  }

  for(i = Caches.begin(), e = Caches.end(); i != e; i++){
    value2 = (*i)->readLine(tid,inst,addr);
     if( (value1 != value2) && (value2 != INT_NAN) ) {printf("---------------------------------------------------------------ERROR -> mismatch.... required (%d==%d)\n", value1, value2); if(stopOnError)exit(1);}
    //if( (value1 != value2) ) {printf("---------------------------------------------------------------ERROR -> mismatch.... required (%d==%d)\n", value1, value2); if(stopOnError)exit(1);}
    else if (enable_prints) //printf("---------------------------------------------------------------value matched!! yayyeee!!\n");
    
    if(useRef && (stopOnError || printOnError)){
      if( ReferenceProtocol->getStateAsInt(tid,addr) !=
          (*i)->getStateAsInt(tid,addr)
        ){
        if(printOnError){
          printf("---------------------------------------------------------------[MCS-Read] State of Protocol %s did not match the reference\nShould have been %d but it was %d\n",
                  (*i)->Identify(),
                  ReferenceProtocol->getStateAsInt(tid,addr),
                  (*i)->getStateAsInt(tid,addr));
          }
        if(stopOnError){
          exit(1);
        }
      }
    }
  }
      
  PIN_ReleaseLock(&globalLock);
}

void Write(THREADID tid, ADDRINT addr, ADDRINT inst){

  if (!instrumentationStatus[PIN_ThreadId()]) { // Only do instrumentation if do_instrumentation is true.
    return;
  }

  PIN_GetLock(&globalLock, 1);

  writeaddr = addr;
  writetid  = tid;
  writeinst = inst;
  writecount++;
  //if (enable_prints) printf("---------------------------------------------------------------Write: ADDR: %lx...... writecount=%ld\n", addr, writecount);

  PIN_ReleaseLock(&globalLock);
}

void WriteData(){ //Should add all the necessary arguments for updating the virtual cache
  
  if (!instrumentationStatus[PIN_ThreadId()]) { // Only do instrumentation if do_instrumentation is true.
    return;
  }

  //if (isStack(writeaddr)) {if (enable_prints) printf("---------------------------------------------------------------access to the stack , hence ignoring %lx\n",writeaddr); writecount=0; return;}

  if (isStack(writeaddr)) {if (0) printf("---------------------------------------------------------------access to the stack , hence ignoring %lx\n",writeaddr); writecount=0; return;}

  PIN_GetLock(&globalLock, 1);

  //Reading from memory
  if (writecount > 0){

    ADDRINT * addr_ptr = (ADDRINT*)writeaddr;
    ADDRINT value;
    PIN_SafeCopy(&value, addr_ptr, sizeof(ADDRINT));

    if (enable_prints) printf("---------------------------------------------------------------Write: ADDR, writecount, Value: %lx, %lx, %lx\n", writeaddr, writecount, value);  

    if (henry_debug) {
      printf("CPU %d -- WRITE:\tAddress:%lx,\tValue:%lx\n", writetid, writeaddr, value);
    }

    writecount--;
    
    if (useSCL) {
      // TODO for write update
    }

    if(useRef){
      ReferenceProtocol->writeLine(writetid,writeinst,writeaddr,value);
    }
    std::vector<MultiCacheSim *>::iterator i,e;

    for(i = Caches.begin(), e = Caches.end(); i != e; i++){

      (*i)->writeLine(writetid,writeinst,writeaddr,value);

      if(useRef && (stopOnError || printOnError)){

	if( ReferenceProtocol->getStateAsInt(writetid,writeaddr) !=
	    (*i)->getStateAsInt(writetid,writeaddr)
	    ){
	  if(printOnError){
	    printf("---------------------------------------------------------------[MCS-Write] State of Protocol %s did not match the reference\nShould have been %d but it was %d\n",
		    (*i)->Identify(),
		    ReferenceProtocol->getStateAsInt(writetid,writeaddr),
		    (*i)->getStateAsInt(writetid,writeaddr));
	  }
	  if(stopOnError){
	    exit(1);
	  }
	}
      }
    }
  }
  PIN_ReleaseLock(&globalLock);
}

VOID instrumentTrace(TRACE trace, VOID *v)
{

  for (BBL bbl = TRACE_BblHead(trace); BBL_Valid(bbl); bbl = BBL_Next(bbl)) {
    for (INS ins = BBL_InsHead(bbl); INS_Valid(ins); ins = INS_Next(ins)) {  
        INS_InsertCall(ins, 
			 IPOINT_BEFORE, 
			 (AFUNPTR)WriteData, 
			 IARG_END);
      if(INS_IsMemoryRead(ins)) {
	  INS_InsertCall(ins, 
			 IPOINT_BEFORE, 
			 (AFUNPTR)Read, 
			 IARG_THREAD_ID,
			 IARG_MEMORYREAD_EA,
			 IARG_INST_PTR,
			 IARG_END);
      } else if(INS_IsMemoryWrite(ins)) {
	  INS_InsertCall(ins, 
			 IPOINT_BEFORE, 
			 (AFUNPTR)Write, 
			 IARG_THREAD_ID,//thread id
			 IARG_MEMORYWRITE_EA,//address being accessed
			 IARG_INST_PTR,//instruction address of write
			 IARG_END);
      }
    }
  }
}


VOID threadBegin(THREADID threadid, CONTEXT *sp, INT32 flags, VOID *v)
{
  
}
    
VOID threadEnd(THREADID threadid, const CONTEXT *sp, INT32 flags, VOID *v)
{

}

VOID dumpInfo(){
}


VOID Fini(INT32 code, VOID *v)
{
  
  std::vector<MultiCacheSim *>::iterator i,e;
  for(i = Caches.begin(), e = Caches.end(); i != e; i++){
    PIN_GetLock(&globalLock,1);
    (*i)->dumpStatsForAllCaches(KnobConcise.Value());
    PIN_ReleaseLock(&globalLock);
  }
  
}

BOOL segvHandler(THREADID threadid,INT32 sig,CONTEXT *ctx,BOOL hasHndlr,const EXCEPTION_INFO *pExceptInfo, VOID*v){
  return TRUE;//let the program's handler run too
}

BOOL termHandler(THREADID threadid,INT32 sig,CONTEXT *ctx,BOOL hasHndlr,const EXCEPTION_INFO *pExceptInfo, VOID*v){
  return TRUE;//let the program's handler run too
}


int main(int argc, char *argv[])
{
  PIN_InitSymbols();
  if( PIN_Init(argc,argv) ) {
    return usage();
  }

  PIN_InitLock(&globalLock);
  
  for(int i = 0; i < MAX_NTHREADS; i++){
    instrumentationStatus[i] = false;
  }

  unsigned long csize = KnobCacheSize.Value();
  unsigned long bsize = KnobBlockSize.Value();
  unsigned long assoc = KnobAssoc.Value();
  unsigned long num = KnobNumCaches.Value();

  MultiCacheSim *c;

  const char *pstr = KnobProtocol.Value().c_str();
  char *ct = strtok((char *)pstr,",");
  while(ct != NULL){

    printf("---------------------------------------------------------------Opening protocol \"%s\"\n",ct);
    void *chand = dlopen( ct, RTLD_LAZY | RTLD_LOCAL );
    if( chand == NULL ){
      printf("---------------------------------------------------------------Couldn't Load %s\n", argv[1]);
      printf("---------------------------------------------------------------dlerror: %s\n", dlerror());
      exit(1);
    }
  
    CacheFactory cfac = (CacheFactory)dlsym(chand, "Create");

    if( chand == NULL ){

      printf("---------------------------------------------------------------Couldn't get the Create function\n");
      printf("---------------------------------------------------------------dlerror: %s\n", dlerror());
      exit(1);

    }

    c = new MultiCacheSim(stdout, csize, assoc, bsize, cfac);

    for(unsigned int i = 0; i < num; i++){
      c->createNewCache();
    } 

    Caches.push_back(c);

    ct = strtok(NULL,","); 

  }

  useRef = KnobUseReference.Value();
  if(useRef){
    void *chand = dlopen( KnobReference.Value().c_str(), RTLD_LAZY | RTLD_LOCAL );
    if( chand == NULL ){
      printf("---------------------------------------------------------------Couldn't Load Reference: %s\n", argv[1]);
      printf("---------------------------------------------------------------dlerror: %s\n", dlerror());
      exit(1);
    }
  
    CacheFactory cfac = (CacheFactory)dlsym(chand, "Create");
    if( chand == NULL ){
      printf("---------------------------------------------------------------Couldn't get the Create function\n");
      printf("---------------------------------------------------------------dlerror: %s\n", dlerror());
      exit(1);
    }
  
    ReferenceProtocol = 
      new MultiCacheSim(stdout, csize, assoc, bsize, cfac);
  
    for(unsigned int i = 0; i < num; i++){

      ReferenceProtocol->createNewCache();

    } 

    printf("---------------------------------------------------------------Using Reference Implementation %s\n",KnobReference.Value().c_str());

  }

  useSCL = KnobUseSCL.Value();
  if (useSCL && c) {
    //printf("---------------------------------------------------------------Using Speculative Cache Lookup.\n");

    void *chand = dlopen( KnobSCL.Value().c_str(), RTLD_LAZY | RTLD_LOCAL );
    if( chand == NULL ){
      printf("---------------------------------------------------------------Couldn't Load SCL: %s\n", argv[1]);
      printf("---------------------------------------------------------------dlerror: %s\n", dlerror());
      exit(1);
    }
  
    CacheFactory cfac = (CacheFactory)dlsym(chand, "Create");
    if( chand == NULL ){
      printf("---------------------------------------------------------------Couldn't get the Create function\n");
      printf("---------------------------------------------------------------dlerror: %s\n", dlerror());
      exit(1);
    }
  
    MultiCacheSim *sc = new MultiCacheSim(stdout, csize, assoc, bsize, cfac);

    for(unsigned int i = 0; i < num; i++){
      sc->createNewSCL(c->allCaches[i]);
    } 

    SCL_Caches.push_back(sc);

    printf("---------------------------------------------------------------Using SCL Implementation %s\n",KnobSCL.Value().c_str());

  }

  stopOnError = KnobStopOnError.Value();
  printOnError = KnobPrintOnError.Value();

  RTN_AddInstrumentFunction(instrumentRoutine,0);
  IMG_AddInstrumentFunction(instrumentImage, 0);
  TRACE_AddInstrumentFunction(instrumentTrace, 0);

  PIN_InterceptSignal(SIGTERM,termHandler,0);
  PIN_InterceptSignal(SIGSEGV,segvHandler,0);

  PIN_AddThreadStartFunction(threadBegin, 0);
  PIN_AddThreadFiniFunction(threadEnd, 0);
  PIN_AddFiniFunction(Fini, 0);
    
  //printf("---------------------------------------------------------------Using Protocol %s\n",KnobReference.Value().c_str());
 
  PIN_StartProgram();
  
  return 0;
}
