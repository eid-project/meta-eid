inherit debianize
inherit sbuild

SRC_URI = "file://hoge \
           file://hoge.conf \
           file://Makefile"

do_debianize_prepend() {
	# setup source tree
	install -d ${S}
	install -m 0755 ${WORKDIR}/hoge ${S}
	install -m 0644 ${WORKDIR}/hoge.conf ${S}
	install -m 0644 ${WORKDIR}/Makefile ${S}
}
