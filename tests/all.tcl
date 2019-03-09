#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"

source tools.tcl

test_cleantmp_all

# write test files
if {![file exists tmp/data.txt] || ![file exists tmp/data.txt.zst]} {
	puts "Making test data"
	set f [open tmp/data.txt w]
	for {set i 1} {$i < 4000000} {incr i} {
		puts $f $i
	}
	close $f
	exec zstd-mt -8 -T 1 -b 1 -f -k tmp/data.txt -o tmp/data.txt.zst
}
file delete tmp/data.txt.zst.zsti

proc expected {expectedfile args} {
	set f [open tmp/data.txt]
	fconfigure $f -encoding binary
	set o [open $expectedfile w]
	fconfigure $o -encoding binary
	foreach {begin size} $args {
		seek $f $begin
		if {$size eq ""} {
			fcopy $f $o
		} else {
			set temp [read $f $size]
			puts -nonewline $o $temp
		}
	}
	close $o
	close $f
}

test zstdra {basic 0} {
	test_cleantmp
	expected tmp/expected.txt 0
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 0 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {basic 0 100} {
	test_cleantmp
	expected tmp/expected.txt 0 100
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 0 100 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {basic 0 8000000} {
	test_cleantmp
	expected tmp/expected.txt 0 8000000
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 0 8000000 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {basic 0 100 10 100} {
	test_cleantmp
	expected tmp/expected.txt 0 100 10 100
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 0 100 10 100 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {basic 2000000 100 2000010 100} {
	test_cleantmp
	expected tmp/expected.txt 2000000 100 2000010 100
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 2000000 100 2000010 100 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {basic 8000000 4000000} {
	test_cleantmp
	expected tmp/expected.txt 8000000 4000000
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 8000000 4000000 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {multiple parts 0 100 500 1000} {
	test_cleantmp
	expected tmp/expected.txt 0 100 500 1000
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 0 100 500 1000 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {multiple parts 0 100 8000000 1000} {
	test_cleantmp
	expected tmp/expected.txt 0 100 8000000 1000
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 0 100 8000000 1000 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {multiple parts 8000000 4000000 500 1000} {
	test_cleantmp
	expected tmp/expected.txt 8000000 4000000 500 1000
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 8000000 4000000 500 1000 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {0 500} {
	test_cleantmp
	expected tmp/expected.txt 0 500
	file delete tmp/result.txt
	exec ../bin/zstdra tmp/data.txt.zst 0 500 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdindex {index 0 500} {
	test_cleantmp
	expected tmp/expected.txt 0 500
	file delete tmp/result.txt
	exec ../bin/zstdindex tmp/data.txt.zst 2>@ stdout
	exec ../bin/zstdra tmp/data.txt.zst 0 500 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdindex {index 0 500 10 100} {
	test_cleantmp
	expected tmp/expected.txt 0 500 10 100
	file delete tmp/result.txt
	exec ../bin/zstdindex tmp/data.txt.zst 2>@ stdout
	exec ../bin/zstdra tmp/data.txt.zst 0 500 10 100 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdindex {index 8000000 100} {
	test_cleantmp
	expected tmp/expected.txt 8000000 100
	file delete tmp/result.txt
	exec ../bin/zstdindex tmp/data.txt.zst 2>@ stdout
	exec ../bin/zstdra tmp/data.txt.zst 8000000 100 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdindex {index 8000000 4000000} {
	test_cleantmp
	expected tmp/expected.txt 8000000 4000000
	file delete tmp/result.txt
	exec ../bin/zstdindex tmp/data.txt.zst 2>@ stdout
	exec ../bin/zstdra tmp/data.txt.zst 8000000 4000000 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {index multiple parts 8000000 4000000 500 1000} {
	test_cleantmp
	expected tmp/expected.txt 8000000 4000000 500 1000
	file delete tmp/result.txt
	exec ../bin/zstdindex tmp/data.txt.zst 2>@ stdout
	exec ../bin/zstdra tmp/data.txt.zst 8000000 4000000 500 1000 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {index multiple parts 0 100 8000000 1000} {
	test_cleantmp
	expected tmp/expected.txt 0 100 8000000 1000
	file delete tmp/result.txt
	exec ../bin/zstdindex tmp/data.txt.zst 2>@ stdout
	exec ../bin/zstdra tmp/data.txt.zst 0 100 8000000 1000 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}

test zstdra {no size given} {
	test_cleantmp
	expected tmp/expected.txt 30800000
	file delete tmp/result.txt
	exec ../bin/zstdindex tmp/data.txt.zst 2>@ stdout
	exec ../bin/zstdra tmp/data.txt.zst 30800000 > tmp/result.txt
	exec diff tmp/result.txt tmp/expected.txt
} {}
