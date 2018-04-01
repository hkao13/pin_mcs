#include "CompressionModule.h"

// Henry -- TODO implement the compression and decompression modules here

linedata_t xorCompress (linedata_t target, linedata_t partner) {
	//TODO
	int dataMaxSize = 256; // Hard coded in CacheCore.h, change this if that changes
	int i;
	linedata_t compressedLine;
	for (i = 0; i < dataMaxSize; i++) {
		compressedLine.data[i] = target.data[i] ^ partner.data[i];
	}

	return compressedLine;
}