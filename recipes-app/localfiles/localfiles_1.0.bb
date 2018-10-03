inherit debianize

SRC_URI = "file://hoge \
           file://hoge.conf"

# dummy install
do_build() {
	rm -rf ${D}
	install -d ${D}/${bindir} ${D}/${sysconfdir}
	install -m 0755 ${WORKDIR}/hoge ${D}/${bindir}
	install -m 0644 ${WORKDIR}/hoge.conf ${D}/${sysconfdir}
}
