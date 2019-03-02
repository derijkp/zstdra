#!/bin/bash

# This script builds zstd and esp. the libraries needed by zstdra using the Holy build box environment
# If you give the parameter 32, a 32bit build will be made

# The Holy build box environment requires docker, make sure it is installed
# e.g. on ubuntu and derivatives
# sudo apt install docker.io
# Also make sure you have permission to use docker
# sudo usermod -a -G docker $USER

# stop on error
set -e

# check if we are already in holy build box
if [ ! -f /hbb_exe/activate ]; then
	# find directory of script
	script="$(readlink -f "$0")"
	dir="$(dirname "$script")"
	file="$(basename "$script")"
	echo "Running script $dir/$file"
	# we go one dir below (script is in build dir)
	cd $dir/..
	# run the script in holy build box
	if [ "$1" = "32" ]
	then
		docker run -t -i --rm -v `pwd`:/io phusion/holy-build-box-32:latest linux32 bash /io/build/$file '-ix86'
	else
		docker run -t -i --rm -v `pwd`:/io phusion/holy-build-box-64:latest bash /io/build/$file
	fi
	exit
fi

echo "Entering Holy Build Box environment"

# Activate Holy Build Box environment.
source /hbb_exe/activate

export ARCH="$1"
echo "building zstd-$ARCH"

# print all executed commands to the terminal
set -x

# Compile
cd /io/zstd-ori/zstd-1.3.8$ARCH
make clean
make

echo "Finished building zstd-1.3.8$ARCH"
