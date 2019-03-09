#include "zstdtools.h"

void zstdindex(char* filename) {
	FILE *finput, *findex;
	char *indexfile;
	off64_t binsizepos, sizepos, framesizepos, start, binsize;
	uint64_t framesize=0;
	int lastblock = 0;
	indexfile = zstd_findindex(filename);
	remove(indexfile);
	findex = fopen(indexfile, "w+");
	fprintf(findex,"#bym zsti\n");
	fprintf(findex,"---\n");
	fprintf(findex,"name: zstindex\n");
	fprintf(findex,"version: 0.1\n");
	fprintf(findex,"type: array\n");
	fprintf(findex,"datatype: uint64\n");
	fprintf(findex,"byteorder: l\n");
	fprintf(findex,"usize:               \n");
	sizepos = ftello(findex) - 15;
	fprintf(findex,"binsize:               \n");
	binsizepos = ftello(findex) - 15;
	fprintf(findex,"framesize:               \n");
	framesizepos = ftello(findex) - 15;
	fprintf(findex,"#binary data follows");
	/* pad if needed till 8 byte aligned */
	start = ftello(findex) + 5;
	while (start%8) {
		fprintf(findex," ");
		start++;
	}
	fprintf(findex,"\n");
	fprintf(findex,"...\n");
	/* open zst file */
	finput = fopen64_or_die(filename, "r");
	ZSTDres *res=zstdopen(finput,NULL);
	while (1) {
		if (feof(res->finput)) break;
		if (res->contentsize > 0) {
			if (framesize == 0) {
				framesize = res->contentsize;
			} else if (res->contentsize != framesize) {
				if (lastblock) {
					fprintf(stderr,"All frames (ecept last) must have the same contentsize for indexing (use e.g. zstd-mt -b 1 -T 1 to make this happen)");
					exit(1);
				}
				lastblock = 1;
			}
			DPRINT("pos:       %lld",(long long int)res->framefilepos);
			zstdindex_write(findex,res->framefilepos);
		}
		zstd_skipframe(res);
		zstd_readheader(res);
	}
	binsize = ftello(findex)-start;
	DPRINT("binsize=%llu",(unsigned long long)start);
	zstdclose(res);
	DPRINT("sizepos=%llu",(unsigned long long)sizepos);
	DPRINT("uncompressedsize=%llu",(res->framepos + res->contentsize));
	fseeko(findex,sizepos,SEEK_SET);
	fprintf(findex,"%llu",res->framepos + res->contentsize);
	DPRINT("binsizepos=%llu",(unsigned long long)binsizepos);
	DPRINT("binsize=%llu",(unsigned long long)binsize);
	fseeko(findex,binsizepos,SEEK_SET);
	fprintf(findex,"%llu",(unsigned long long)binsize);
	fseeko(findex,framesizepos,SEEK_SET);
	fprintf(findex,"%llu",(unsigned long long)framesize);
	fclose(findex);
}


int main(int argc, char** argv) {
	if(argc != 2) {
		printf("format is: zstdindex filename\n");
		return 0;
	}
	zstdindex(argv[1]);
	return 0;
}

