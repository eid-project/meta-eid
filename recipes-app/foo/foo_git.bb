inherit debianize
inherit sbuild

PV = "1.0"

SRC_URI = "git://github.com/zuka0828/${PN}.git;protocol=https"
SRCREV = "063bf707a9bc0169469beec0681341ee296b5679"

S = "${WORKDIR}/git"

DEPENDS += "baz"
DEB_DEPENDS = "baz libssl-dev"
DEB_RDEPENDS = "bc"
