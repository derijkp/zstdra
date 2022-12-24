/*
 * Copyright (c) 2018-present, Peter De Rijk VIB/University of Antwerp
 *
 * This source code is licensed under the BSD-style license
 */

/* very simple decompress for testing */

#include "zstdtools.h"
#include <sys/stat.h>

void decompress(ZSTDres *res,FILE *foutput) {
	char *writebuffer;
	unsigned int skip, writesize;
	/* allways do seek, deals with e.g. start with a skippable frame */
	if (!zstd_seek(res, 0, SEEK_SET)) {
		fprintf(stderr,"could not go to start in file (uncompressed frame size: %lld)",res->framepos + res->contentsize);
		exit(1);
	}
	skip = 0;
	DPRINT("skip: %d",skip);
	/* decompress */
	while (1) {
		if (res->contentsize > 0) {
			if (!res->frameread) zstd_readframe(res);
			writebuffer = res->outbuffer + skip;
			writesize = res->contentsize - skip;
			skip = 0;
			fwrite(writebuffer,1,writesize,foutput);
		} else {
			zstd_skipframe(res);
		}
		zstd_readheader(res);
		if (feof(res->finput)) break;
	}
}

/* (finaly) found some example/info for debuging blocks in ZSTD_findFrameSizeInfo */
void decompressmem(char *filename,FILE *foutput) {
	FILE *finput;
	struct stat st;
	char *readbuffer,*writebuffer;
	unsigned long long writesize;
	finput = fopen64_or_die(filename, "r");
	if (stat(filename, &st) != 0) {
		/* error */
		exit(1);
	}
	off_t const fileSize = st.st_size;
	readbuffer = (char *)malloc(fileSize);
	// just take 400M
	writebuffer = (char *)malloc(400*1024*1024);
	fread(readbuffer,fileSize,1,finput);
	writesize = ZSTD_decompressBound(readbuffer,fileSize);
	ZSTD_decompress(writebuffer, 400*1024*1024, readbuffer, fileSize);
	fwrite(writebuffer,writesize,1,foutput);
}


int main(int argc, char** argv) {
	ZSTDres *res;
	FILE *finput;
	if(argc < 2) {
		fprintf(stderr,"format is: zstdra filename\n");
		return 1;
	}
/*
	finput = fopen64_or_die(argv[1], "r");
	res = zstdopen(finput,NULL);
	decompressmem(res, stdout);
	zstdclose(res);
*/
	decompressmem(argv[1],stdout);
	return 0;
}

