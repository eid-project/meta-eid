# class file for non-Debian sources

inherit common

# build with Debian package builder
inherit sbuild

do_debianize[dirs] = "${S}"
do_debianize() {
	# TODO: need to change the package type? (e.g. --library)
	dh_make -y -p "${PN}_${PV}" --createorig --single
	rm -f ${S}/debian/*.ex ${S}/debian/*.EX

	# embed build dependencies in recipes into debian/control
	deplist=""
	for dep in ${DEB_DEPENDS}; do
		deplist=", ${dep}"
	done
	sed -i "s@^\(Build-Depends: .*\)@\1${deplist}@" ${S}/debian/control
}
addtask debianize after do_unpack before do_sbuild
