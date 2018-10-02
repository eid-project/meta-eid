inherit common

do_build[dirs] = "${S}"
do_build () {
	sbuild --arch ${DEBIAN_ARCH} -d ${DEBIAN_CODENAME}
}
