inherit debianize
inherit sbuild

PV = "1.0"

SRC_URI = "git://github.com/eid-project/${PN}.git;protocol=https"
SRCREV = "759a1ce94da5a4702144f2058feb32af18c8a75e"

S = "${WORKDIR}/git"

do_debianize_append() {
	echo "libbaz 1 baz" > ${S}/debian/baz.shlibs
	echo "${libdir}/libbaz.so ${libdir}/libbaz.so.1" > ${S}/debian/baz.links
}
