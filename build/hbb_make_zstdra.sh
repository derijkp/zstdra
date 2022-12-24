#!/bin/bash

# This script builds the zstdra and zstdindex binaries using the Holy build box environment
# options:
# -b|-bits|--bits: 32 for 32 bits build (default 64)
# -d|-builddir|--builddir: top directory to build external software in (default ~/build/bin-$arch)
# -c|-clean|--clean: 1 to do "make clean" before building (default), use 0 to not run make clean

# The Holy build box environment requires docker, make sure it is installed
# e.g. on ubuntu and derivatives
# sudo apt install docker.io
# Also make sure you have permission to use docker
# sudo usermod -a -G docker $USER

## If it does not find the required zstd libraries in builddir, it will make it

# stop on error
set -e

# Prepare and start docker with Holy Build box
# ============================================

script="$(readlink -f "$0")"
dir="$(dirname "$script")"
source "${dir}/start_hbb.sh"

# Parse arguments
# ===============

clean=1
debug=0
while [[ "$#" -gt 0 ]]; do case $1 in
	-c|-clean|--clean) clean="$2"; shift;;
	-d|-debug|--debug) debug="$2"; shift;;
	*) echo "Unknown parameter: $1"; exit 1;;
esac; shift; done

# Script run within Holy Build box
# ================================

echo "Entering Holy Build Box environment"

# Activate Holy Build Box environment.
source /hbb_exe/activate

# print all executed commands to the terminal
set -x

# set up environment
# ------------------

# Deps
# ----
# when changing version, also change it in extern-src/adapted_Makefile_zstd-mt
zstdversion=1.5.2
if [ ! -f /build/zstd-$zstdversion/lib/libzstd.a ] ; then
	source /hbb_shlib/activate
	cd /build
	curl -O -L https://github.com/facebook/zstd/releases/download/v$zstdversion/zstd-$zstdversion.tar.gz
	tar xvzf zstd-$zstdversion.tar.gz
	cd /build/zstd-$zstdversion
	make
	sudo make install
	cd contrib/seekable_format/examples
	make
	source /hbb_exe/activate
fi

zstdmtversion=0.8
if [ ! -f /build/zstdmt-$zstdmtversion/programs/zstd-mt ] ; then
	source /hbb_shlib/activate
	cd /build
	curl -o zstdmt-$zstdmtversion.tar.gz -L https://github.com/mcmilk/zstdmt/archive/v$zstdmtversion.tar.gz
	tar xvzf zstdmt-$zstdmtversion.tar.gz
	cd /build/zstdmt-$zstdmtversion/programs
	if [ ! -f main.c.ori ] ; then
		cp main.c main.c.ori
	fi
	cp /io/extern-src/zstdmt_main.c main.c
	if [ ! -f Makefile.ori ] ; then
		cp Makefile Makefile.ori
	fi
	cp /io/extern-src/adapted_Makefile_zstd-mt Makefile
	make clean
	CPATH="/build/zstd-$zstdversion/lib:/build/zstd-$zstdversion/lib/common:$CPATH" \
		LIBRARY_PATH="/build/zstd-$zstdversion/lib:$LIBRARY_PATH" \
		make zstd-mt
	rm -f /io/extern$ARCH/zstd-mt
	strip zstd-mt
	source /hbb_exe/activate
fi

cp /build/zstdmt-$zstdmtversion/programs/zstd-mt /io/bin$ARCH

# Build
# -----

echo "building zstd-$arch"

# Compile
cd /io/src
if [ "$clean" = 1 ] ; then
	make clean
fi

if [ "$debug" = 1 ] ; then
	CFLAGS_OPT=-g CPATH="/build/zstd-$zstdversion/lib:/build/zstd-$zstdversion/lib/common:/build/zstd-$zstdversion/lib/decompress:/build/zstd-$zstdversion/programs:$CPATH" LIBRARY_PATH="/build/zstd-$zstdversion/lib:$LIBRARY_PATH" make
else
	CPATH="/build/zstd-$zstdversion/lib:/build/zstd-$zstdversion/lib/common:/build/zstd-$zstdversion/lib/decompress:/build/zstd-$zstdversion/programs:$CPATH" LIBRARY_PATH="/build/zstd-$zstdversion/lib:$LIBRARY_PATH" make
fi

echo "Finished building zstdra"
