inherit raw-build

PV = "1.0"

SRC_URI = "file://hoge.c"

do_raw_build() {
	${SCH} gcc hoge.c -o hoge
}
