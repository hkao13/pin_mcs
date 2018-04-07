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
  
  numChildrenRequests = 0;
  numChildrenRequests_total[0] = 0;
  numChildrenRequests_total[1] = 0;
  numChildrenRequests_total[2] = 0;

  /* New stats for true/false sharing for SCL */
  numFalseSharing = 0;
  numTrueSharing = 0;
  /* Speculative Execution stats */
  numCorrectSpeculations = 0;
  numIncorrectSpeculations = 0;

  /* Additional stats for number of write-backs */
  numSilentStores = 0;
  numSilentEvictions = 0;
  numReplacements = 0;
  numWritebacksReceived = 0;

}

void SMPCache::conciseDumpStatsToFile(FILE* outFile){

  fprintf(outFile,"%lu,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                  CPUId,
                  numReadHits,
                  numReadMisses,
                  numReadOnInvalidMisses,
                  numReadRequestsSent,
                  numReadMissesServicedByOthers,
                  numReadMissesServicedByShared,
                  numReadMissesServicedByModified,
                  numFalseSharing,
                  numTrueSharing,
                  numWriteHits,
                  numWriteMisses,
                  numWriteOnSharedMisses,
                  numWriteOnInvalidMisses,
                  numInvalidatesSent,
                  numReplacements,
                  numWritebacksReceived,
                  numChildrenRequests);

}

void SMPCache::dumpStatsToFile(FILE* outFile){
  fprintf(outFile, "-----Cache %lu-----\n",CPUId);

  fprintf(outFile, "Read Hits:                      %6d\n",numReadHits);
  fprintf(outFile, "Read Misses:                    %6d\n",numReadMisses);
  fprintf(outFile, "Total Reads:                    %6d\n",numReadMisses + numReadHits);
  fprintf(outFile, "Read-On-Invalid Misses:         %6d\n",numReadOnInvalidMisses);
  fprintf(outFile, "Read Requests Sent:             %6d\n",numReadRequestsSent);
  fprintf(outFile, "Rd Misses Serviced Remotely:    %6d\n",numReadMissesServicedByOthers);
  fprintf(outFile, "Rd Misses Serviced by Shared:   %6d\n",numReadMissesServicedByShared);
  fprintf(outFile, "Rd Misses Serviced by Modified: %6d\n",numReadMissesServicedByModified);
  fprintf(outFile, "Rd Misses from False Sharing:   %6d\n", numFalseSharing);
  fprintf(outFile, "Rd Misses from True Sharing:    %6d\n", numTrueSharing);
  fprintf(outFile, "\n");
  fprintf(outFile, "Write Hits:                     %6d\n",numWriteHits);
  fprintf(outFile, "Write Misses:                   %6d\n",numWriteMisses);
  fprintf(outFile, "Total Writes:                   %6d\n",numWriteMisses + numWriteHits);  
  fprintf(outFile, "Write-On-Shared Misses:         %6d\n",numWriteOnSharedMisses);
  fprintf(outFile, "Write-On-Invalid Misses:        %6d\n",numWriteOnInvalidMisses);
  fprintf(outFile, "Invalidates Sent:               %6d\n",numInvalidatesSent);
  fprintf(outFile, "Silent Stores:                  %6d\n",numSilentStores);
  fprintf(outFile, "Silent Evictions                %6d\n",numSilentEvictions);
  fprintf(outFile, "\n");                           
  fprintf(outFile, "Replacements:                   %6d\n",numReplacements);
  fprintf(outFile, "Writebacks Received:            %6d\n",numWritebacksReceived);
  fprintf(outFile, "\n");                           
  fprintf(outFile, "Correct Speculations:           %6d\n",numCorrectSpeculations);
  fprintf(outFile, "Incorrect Speculations:         %6d\n",numIncorrectSpeculations);
  fprintf(outFile, "\n");
  fprintf(outFile, "Children Requests useful:       %6d\n",numChildrenRequests);
  fprintf(outFile, "Children Requests not useful[0]:%6d\n",numChildrenRequests_total[0]);
  fprintf(outFile, "Children Requests not useful[1]:%6d\n",numChildrenRequests_total[1]);
  fprintf(outFile, "Children Requests not useful[2]:%6d\n",numChildrenRequests_total[2]);
  fprintf(outFile, "Children Requests total:        %6d\n",(numChildrenRequests_total[0]+
                                                            numChildrenRequests_total[1]+
                                                            numChildrenRequests_total[2]+
                                                            numChildrenRequests));
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
