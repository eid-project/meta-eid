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
	# TODO: consider cases where there are multiple binary packages
	deplist=""
	# Recipes (assumes that they generates same name packages) in DEPENDS
	# should be automatically added to Build-Depends
	for dep in ${DEB_DEPENDS} ${DEPENDS}; do
		deplist="${deplist}, ${dep}"
	done
	sed -i "s@^\(Build-Depends: .*\)@\1${deplist}@" ${S}/debian/control

	# embed run-time dependencies in recipes into debian/control
	deplist=""
	for dep in ${DEB_RDEPENDS}; do
		deplist="${deplist}, ${dep}"
	done
	sed -i "s@^\(Depends: .*\)@\1${deplist}@" ${S}/debian/control
}
addtask debianize after do_unpack before do_sbuild
