#include "zstdtools.h"

void decompressra(ZSTDres *res,FILE *foutput,unsigned long long start,unsigned long long size) {
	char *writebuffer;
	unsigned int skip, writesize;
	DPRINT("start: %lld",start);
	/* allways do seek, deals with e.g. start with a skippable frame */
	if (!zstd_seek(res, start, SEEK_SET)) {
		fprintf(stderr,"could not go to position %lld in file (uncompressed frame size: %lld)",start,res->framepos + res->contentsize);
		exit(1);
	}
	skip = start - res->framepos;
	DPRINT("skip: %d",skip);
	/* decompress */
	while (1) {
		if (size == 0) break;
		if (res->contentsize > 0) {
			zstd_readframe(res);
			writebuffer = res->outbuffer + skip;
			writesize = res->contentsize - skip;
			skip = 0;
			if (writesize > size) {
				writesize = size; size = 0;
			} else {
				size -= writesize;
			}
			fwrite(writebuffer,1,writesize,foutput);
		} else {
			zstd_skipframe(res);
		}
		if (size == 0) break;
		zstd_readheader(res);
		if (feof(res->finput)) break;
	}
}

int main(int argc, char** argv) {
	ZSTDres *res;
	unsigned long long start = 0,size = ULLONG_MAX;
	int i;
	if(argc < 2) {
		fprintf(stderr,"format is: zstdra filename ?start? ?size? ...\n");
		return 1;
	}
	if (argc > 2) {
		start = atoll(argv[2]);
		if (argc > 3) {
			size = atoll(argv[3]);
		}
	}
	i = 4;
	res = zstd_openfile(argv[1]);
	while(1) {
		decompressra(res, stdout, start, size);
		if (i >= argc) break;
		start = atoll(argv[i++]);
		if (i >= argc) {
			size = ULLONG_MAX;
		} else {
			size = atoll(argv[i++]);
		}
	}
	zstdclose(res);
	return 0;
}

