#include "SMPCache.h"

SMPCache::SMPCache(int cpuid, std::vector<SMPCache * > * same, SMPCache *next, std::vector<SMPCache * > * prev){ 
//(CPUID, Siblings, Parent, Children), 2nd attribute was cacheVector->same, 3rd was main->next

  CPUId = cpuid;
  siblings = same;
  parent = next;
  children = prev;

  numReadHits = 0;
  numReadMisses = 0;
  numReadOnInvalidMisses = 0;
  numReadRequestsSent = 0;
  numReadMissesServicedByOthers = 0;
  numReadMissesServicedByShared = 0;
  numReadMissesServicedByModified = 0;

  numWriteHits = 0;
  numWriteMisses = 0;
  numWriteOnSharedMisses = 0;
  numWriteOnInvalidMisses = 0;
  numInvalidatesSent = 0;

  /* New stats for true/false sharing for SCL */
  numFalseSharing = 0;
  numFalseSharingSilentStore = 0;
  numTrueSharing = 0;
  /* Speculative Execution stats */
  numCorrectSpeculations = 0;
  numIncorrectSpeculations = 0;
  numCorrectApproxSpeculations = 0;

  /* Additional stats for number of write-backs */
  numSilentStores = 0;
  numReplacements = 0;
  numWritebacksReceived = 0;

}

void SMPCache::conciseDumpStatsToFile(FILE* outFile){

  fprintf(outFile,"%lu,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                  CPUId,
                  numReadHits,
                  numReadMisses,
                  numReadOnInvalidMisses,
                  numReadRequestsSent,
                  numReadMissesServicedByOthers,
                  numReadMissesServicedByShared,
                  numReadMissesServicedByModified,
                  numFalseSharing,
                  numFalseSharingSilentStore,
                  numTrueSharing,
                  numWriteHits,
                  numWriteMisses,
                  numWriteOnSharedMisses,
                  numWriteOnInvalidMisses,
                  numInvalidatesSent,
                  numSilentStores,
                  numReplacements,
                  numWritebacksReceived,
                  numCorrectSpeculations,
                  numCorrectApproxSpeculations,
                  numIncorrectSpeculations);

}

void SMPCache::dumpStatsToFile(FILE* outFile){
  fprintf(outFile, "-----Cache %lu-----\n",CPUId);

  fprintf(outFile, "Read Hits:                   %d\n",numReadHits);
  fprintf(outFile, "Read Misses:                 %d\n",numReadMisses);
  fprintf(outFile, "Total Reads:                 %d\n",numReadMisses + numReadHits);
  fprintf(outFile, "Read-On-Invalid Misses:      %d\n",numReadOnInvalidMisses);
  fprintf(outFile, "Read Requests Sent:          %d\n",numReadRequestsSent);
  fprintf(outFile, "Rd Misses Serviced Remotely: %d\n",numReadMissesServicedByOthers);
  fprintf(outFile, "Rd Misses Serviced by Shared: %d\n",numReadMissesServicedByShared);
  fprintf(outFile, "Rd Misses Serviced by Modified: %d\n",numReadMissesServicedByModified);
  fprintf(outFile, "Rd Misses from False Sharing: %d\n", numFalseSharing);
  fprintf(outFile, "Rd Misses from Silent Stores: %d\n", numFalseSharingSilentStore);
  fprintf(outFile, "Rd Misses from True Sharing:  %d\n", numTrueSharing);
  fprintf(outFile, "\n");
  fprintf(outFile, "Write Hits:                  %d\n",numWriteHits);
  fprintf(outFile, "Write Misses:                %d\n",numWriteMisses);
  fprintf(outFile, "Total Writes:                %d\n",numWriteMisses + numWriteHits);  
  fprintf(outFile, "Write-On-Shared Misses:      %d\n",numWriteOnSharedMisses);
  fprintf(outFile, "Write-On-Invalid Misses:     %d\n",numWriteOnInvalidMisses);
  fprintf(outFile, "Invalidates Sent:            %d\n",numInvalidatesSent);
  fprintf(outFile, "Silent Stores:               %d\n",numSilentStores);
  fprintf(outFile, "\n");
  fprintf(outFile, "Replacements:                %d\n",numReplacements);
  fprintf(outFile, "Writebacks Received:         %d\n",numWritebacksReceived);
  fprintf(outFile, "\n");
  fprintf(outFile, "Correct Speculations:        %d\n",numCorrectSpeculations);
  fprintf(outFile, "Approx. Speculations:        %d\n",numCorrectApproxSpeculations);
  fprintf(outFile, "Incorrect Speculations:      %d\n",numIncorrectSpeculations);
  fprintf(outFile, "\n");
}

int SMPCache::getCPUId(){
  return CPUId;
}

int SMPCache::getStateAsInt(uint64_t addr){
  return (int)this->cache->findLine(addr)->getState();
}

std::vector<SMPCache * > *SMPCache::getCacheVector(){
  return siblings;
}
