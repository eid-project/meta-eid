inherit debianize
inherit sbuild

PV = "1.0"

SRC_URI = "git://github.com/zuka0828/${PN}.git;protocol=https"
SRCREV = "e2b053f6e5b2f028bdf3b38cbc32b49822a22a7e"

S = "${WORKDIR}/git"
