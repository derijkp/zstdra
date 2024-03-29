zstdra
======
    by Peter De Rijk (VIB / University of Antwerp)

NAME
----
zstdra - a random access decompressor for the zstd format. 

SYNOPSIS
--------
zstdra filename.zst ?start? ?size? ...

DESCRIPTION
-----------
zstdra can decompress an zst file starting from a given (uncompressed)
position, and continue up to a given (uncompressed) size. The uncompressed
data is sent to stdout. zstdra with only the filename as parameter will
decompress the entire file to stdout. Multiple start size ranges can be
given: the ranges will be concatenated in the output

Files should be compressed using zstd-mt (https://github.com/mcmilk/zstdmt/blob/master/lib/zstd-mt.h) 
rather than plain zstd because it compresses the file in equally sized
(uncompressed) independent chunks that can be skipped or decompressed as
needed, making the access to part of the data more efficient. You can
specify the chunk size (expressed in Mb) using the -b option; smaller values make for finer
grained (and faster) random access but decrease compression efficienty a bit, e.g.
a test file compressed with a chunck size of 1 was 0.015% smaller than one
compressed with chunk size of 0.5.
zstdra will work on default zstd compressed files, but not efficiently.

For even faster random access, an index file (with the name filename.zst.zsti)
can be made using:
zstdindex filename.zst
The zsti file contains a list of the starting positions of the blocks in a
binary format (prepended with a yaml header describing the binary data.
With this index the position of the start block can be obtained directly
without parsing and skipping blocks in the zst file.
Making an index will fail on default zstd compressed files.

BUILDING
--------
zstdra, zstdindex can be build by running make in the
src directory. The build directory contains scripts to build a widely
compatible zstdra binary (build/hbb_make_zstdra.sh) using the Holy Build
Box environment (https://github.com/phusion/holy-build-box). The Holy
Build Box requires docker to be installed and usable.
It also builds a zstd-mt binary patched to go with a newer version of zstd
(1.5.2) After building, the zstdra, zstdindex and zstd-mt binaries are in
the directory bin.

LICENSE
-------

The author hereby grant permission to use, copy, modify, distribute, and
license this software and its documentation for any purpose, provided that
existing copyright notices are retained in all copies and that this notice
is included verbatim in any distributions. No written agreement, license, or
royalty fee is required for any of the authorized uses. Modifications to
this software may be copyrighted by their authors and need not follow the
licensing terms described here, provided that the new terms are clearly
indicated on the first page of each file where they apply.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR
DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES THEREOF,
EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. THIS SOFTWARE IS
PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE NO
OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.

