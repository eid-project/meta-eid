inherit debianize
inherit sbuild

PV = "1.0"

SRC_URI = "git://github.com/zuka0828/${PN}.git;protocol=https"
SRCREV = "65643cf3889e78ec863d80fe6e9c450a83ae327b"

S = "${WORKDIR}/git"

DEPENDS += "baz"
DEB_DEPENDS = "baz"
