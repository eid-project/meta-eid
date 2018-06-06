inherit extra

SRC_URI = "git://github.com/zuka0828/hello.git;protocol=https"
SRCREV = "ae2893efe2d473020120669f363f33611ea323f8"

S = "${WORKDIR}/git"

# dummy build and install
# should be built with Debian toolchain
do_build() {
	cd ${S}
	make
	make install DESTDIR=${D}
}
