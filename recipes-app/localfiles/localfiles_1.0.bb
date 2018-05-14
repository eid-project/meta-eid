inherit extra

SRC_URI = "file://foo \
           file://foo.conf"

# dummy install
do_build() {
	rm -rf ${D}
	install -d ${D}/${bindir} ${D}/${sysconfdir}
	install -m 0755 ${WORKDIR}/foo ${D}/${bindir}
	install -m 0644 ${WORKDIR}/foo.conf ${D}/${sysconfdir}
}
