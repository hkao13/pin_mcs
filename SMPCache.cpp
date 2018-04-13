#include "SMPCache.h"

SMPCache::SMPCache(int cpuid, std::vector<SMPCache * > * same, SMPCache *next, std::vector<SMPCache * > * prev, bool isxor){ 
//(CPUID, Siblings, Parent, Children), 2nd attribute was cacheVector->same, 3rd was main->next

  CPUId = cpuid;
  siblings = same;
  parent = next;
  children = prev;

   is_xor_cache = isxor;
  
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
  
  /* Stats for XOR utilization */
  // For reads
  numNonXorReadHits = 0;
  numXorReadHits = 0;
  numXorReadMissOnDirty = 0;
  numXorReadMissOnNoSharers = 0;
  // For writes
  numXorStoreWithPair = 0;
  numXorStoreNotPairedNoSharers = 0;
  numXorStoreNotPairedNoPair = 0;

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
  if (is_xor_cache) {
    fprintf(outFile, "-----Cache (XOR'd) %lu-----\n",CPUId);
  }
  else {
    fprintf(outFile, "-----Cache %lu-----\n",CPUId);
  }

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
//   fprintf(outFile, "\n");                           
//   fprintf(outFile, "Correct Speculations:           %6d\n",numCorrectSpeculations);
//   fprintf(outFile, "Incorrect Speculations:         %6d\n",numIncorrectSpeculations);

  if (is_xor_cache) {
    fprintf(outFile, "\n");
    fprintf(outFile, "Children Requests useful:       %6d\n",numChildrenRequests);
    fprintf(outFile, "Children Requests not useful[0]:%6d\n",numChildrenRequests_total[0]);
    fprintf(outFile, "Children Requests not useful[1]:%6d\n",numChildrenRequests_total[1]);
    fprintf(outFile, "Children Requests not useful[2]:%6d\n",numChildrenRequests_total[2]);
    fprintf(outFile, "Children Requests total:        %6d\n",(numChildrenRequests_total[0]+
							      numChildrenRequests_total[1]+
							      numChildrenRequests_total[2]+
							      numChildrenRequests));
    //int totalReads = numReadMisses + numReadHits;
    fprintf(outFile, "\n");
    fprintf(outFile, "Non-XOR Read Hits:            %6d, %3.2f%%\n",numNonXorReadHits, ((float)numNonXorReadHits/(float)numReadHits)*100 );
    fprintf(outFile, "XOR Read Hits (Clean Sharer): %6d, %3.2f%%\n",numXorReadHits, ((float)numXorReadHits/(float)numReadHits)*100);
    fprintf(outFile, "XOR Read Miss (Dirty Sharer): %6d, %3.2f%%\n",numXorReadMissOnDirty, ((float)numXorReadMissOnDirty/(float)numReadMisses)*100);
    fprintf(outFile, "XOR Read Miss (No Sharer):    %6d, %3.2f%%\n",numXorReadMissOnNoSharers, ((float)numXorReadMissOnNoSharers/(float)numReadMisses)*100);
    
    fprintf(outFile, "\n");
    fprintf(outFile, "XOR Store Paired:               %6d, %3.2f%%\n",numXorStoreWithPair, ((float)numXorStoreWithPair/(float)numWriteHits)*100 );
    fprintf(outFile, "XOR Store Unpaired (No Pair):   %6d, %3.2f%%\n",numXorStoreNotPairedNoPair, ((float)numXorStoreNotPairedNoPair/(float)numWriteHits)*100 );
    fprintf(outFile, "XOR Store Unpaired (No Sharer): %6d, %3.2f%%\n",numXorStoreNotPairedNoSharers, ((float)numXorStoreNotPairedNoSharers/(float)numWriteHits)*100 );
  }
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
