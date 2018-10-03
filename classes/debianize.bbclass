# class file for non-Debian sources

inherit common

do_debianize[dirs] = "${S}"
do_debianize() {
	# TODO: need to change the package type? (e.g. --library)
	dh_make -y -p "${PN}_${PV}" --createorig --single
	rm -f ${S}/debian/*.ex ${S}/debian/*.EX
}
addtask debianize after do_unpack before do_build
