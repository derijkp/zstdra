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
while [[ "$#" -gt 0 ]]; do case $1 in
	-c|-clean|--clean) clean="$2"; shift;;
	*) echo "Unknown parameter: $1"; exit 1;;
esac; shift; done

# Script run within Holy Build box
# ================================

echo "Entering Holy Build Box environment"

# Activate Holy Build Box environment.
# Tk does not compile with these settings (X)
# only use HBB for glibc compat, not static libs
source /hbb_exe/activate

# print all executed commands to the terminal
set -x

# set up environment
# ------------------

# Deps
# ----
if [ ! -f /build/zstd-1.4.4/lib/libzstd.a ] ; then
	source /hbb_shlib/activate
	cd /build
	curl -O -L https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-1.4.4.tar.gz
	tar xvzf zstd-1.4.4.tar.gz
	cd zstd-1.4.4
	make
	cd contrib/seekable_format/examples
	make
	source /hbb_exe/activate
fi

if [ ! -f /build/zstdmt-0.6/programs/zstd-mt ] ; then
	source /hbb_shlib/activate
	cd /build
	curl -o zstdmt-0.6.tar.gz -L https://github.com/mcmilk/zstdmt/archive/0.6.tar.gz
	tar xvzf zstdmt-0.6.tar.gz
	cd /build/zstdmt-0.6/programs
	make clean
	cp Makefile Makefile.ori
	cp /io/build/adapted_Makefile_zstd-mt Makefile
	CPATH="/build/zstd-1.4.4/lib:/build/zstd-1.4.4/lib/common:$CPATH" \
		LIBRARY_PATH="/build/zstd-1.4.4/lib:$LIBRARY_PATH" \
		make zstd-mt
	source /hbb_exe/activate
fi

cp /build/zstdmt-0.6/programs/zstd-mt /io/bin$ARCH

# Build
# -----

echo "building zstd-$arch"

# Compile
cd /io/src
if [ "$clean" = 1 ] ; then
	make clean
fi

CPATH="/build/zstd-1.4.4/lib:/build/zstd-1.4.4/lib/common:/build/zstd-1.4.4/lib/decompress:/build/zstd-1.4.4/programs:$CPATH" LIBRARY_PATH="/build/zstd-1.4.4/lib:$LIBRARY_PATH" make

echo "Finished building zstdra"
