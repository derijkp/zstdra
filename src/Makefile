# ARCH should be defined by caller
ifndef ARCH
	ARCH=""
endif
BINDIR := $(PREFIX)/bin
MANDIR := $(PREFIX)/share/man/man1
ZSTDDIR := ../zstd-ori/zstd-1.3.8$(ARCH)
ZSTDLIB := $(ZSTDDIR)/lib
ZSTDPROG := $(ZSTDDIR)/programs
ZSTDSRCFILES := $(wildcard $(ZSTDLIB)/*.c) $(wildcard $(ZSTDPROG)/*.c)
ZSTDLIBRARY := $(ZSTDLIB)/libzstd.a

CFLAGS ?= -g
#CFLAGS += -g
CFLAGS += -D_FILE_OFFSET_BITS=64 -std=c99 -Wall -Wextra -Wundef -Wshadow -Wcast-qual -Wcast-align -Wstrict-prototypes -pedantic -DZSTD_VERSION=\"$(RELEASE)\"
FLAGS  := -I$(ZSTDLIB) -I$(ZSTDLIB)/decompress -I$(ZSTDPROG) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS)

# Define *.exe as extension for Windows systems
ifneq (,$(filter Windows%,$(OS)))
EXT =.exe
VOID = nul
else
EXT =
VOID = /dev/null
endif


#default: zstdra zstdindex zstdc
default: zstdra zstdindex

zstdra: zstdra.c zstdtools.c $(ZSTDLIBRARY)
	$(CC) $(FLAGS) $^ -o ../bin$(ARCH)/$@$(EXT)

zstdindex: zstdindex.c zstdtools.c $(ZSTDLIBRARY)
	$(CC) $(FLAGS) $^ -o ../bin$(ARCH)/$@$(EXT)

zstdc: $(ZSTDSRCFILES)
	$(CC) $(FLAGS) -DENABLE_ZSTDC_LEGACY_OPTIONS $^ -o ../bin$(ARCH)/$@$(EXT)

clean:
	@rm -f core *.o *.test tmp* \
        ../bin$(ARCH)/zstdra$(EXT) \
        ../bin$(ARCH)/zstdindex$(EXT) \
        ../bin$(ARCH)/zstdc$(EXT) \
	@echo Cleaning completed
