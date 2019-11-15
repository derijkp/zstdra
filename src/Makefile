# ARCH should be defined by caller
ifndef ARCH
	ARCH=""
endif
BINDIR := $(PREFIX)/bin
MANDIR := $(PREFIX)/share/man/man1
LIBZSTD=-Wl,-Bstatic -lzstd -Wl,-Bdynamic
CLAGS_OPT ?= -O2

CFLAGS += $(CLAGS_OPT) -D_FILE_OFFSET_BITS=64 -Wall -Wextra -Wundef -Wshadow -Wcast-qual -Wcast-align -Wstrict-prototypes -pedantic -DZSTD_VERSION=\"$(RELEASE)\"
FLAGS  := $(CPPFLAGS) $(CFLAGS) $(LDFLAGS)

# Define *.exe as extension for Windows systems
ifneq (,$(filter Windows%,$(OS)))
EXT =.exe
VOID = nul
else
EXT =
VOID = /dev/null
endif

default: zstdra zstdindex

zstdra: zstdra.c zstdtools.c
	echo "CPATH=$(CPATH)"
	$(CC) $(FLAGS) $^ -o ../bin$(ARCH)/$@$(EXT) $(LIBZSTD)

zstdindex: zstdindex.c zstdtools.c
	$(CC) $(FLAGS) $^ -o ../bin$(ARCH)/$@$(EXT) $(LIBZSTD)

clean:
	@rm -f core *.o *.test tmp* \
        ../bin$(ARCH)/zstdra$(EXT) \
        ../bin$(ARCH)/zstdindex$(EXT) \
        ../bin$(ARCH)/zstdc$(EXT) \
	@echo Cleaning completed
