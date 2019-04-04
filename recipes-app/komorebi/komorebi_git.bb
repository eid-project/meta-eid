inherit debianize

SRC_URI = "git://github.com/cheesecakeufo/komorebi;protocol=https"
SRCREV = "0d2348dacd0cedc374065a0cbbbaf4113fbaa07d"
PV = "${SRCREV}"

DEB_DEPENDS = "cmake valac:native libgtk-3-dev libgee-0.8-dev libclutter-gtk-1.0-dev \
               libclutter-1.0-dev libwebkit2gtk-4.0-dev libclutter-gst-3.0-dev"
S = "${WORKDIR}/git"
