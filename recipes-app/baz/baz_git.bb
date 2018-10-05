inherit debianize
inherit sbuild

PV = "1.0"

SRC_URI = "git://github.com/zuka0828/${PN}.git;protocol=https"
SRCREV = "b19232112aa8828fd16eba6d4b69416a0a04d553"

S = "${WORKDIR}/git"
