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

EXTRA_DHCONF := ""
EXTRA_DHBUILD := ""
EXTRA_DHINST := ""

dh_configure() {
	dh_auto_configure -- ${EXTRA_DHCONF}
}

dh_build() {
	dh_auto_build -- ${EXTRA_DHBUILD}
}

dh_install() {
	dh_auto_install -- ${EXTRA_DHINST}
}

dh_clean() {
	dh_auto_clean -- ${EXTRA_DHCLEAN}
}

dh_test() {
	# do nothing
}

# Define necessary variables for dh functions
rules_before_funcs() {
	# DESTDIR
	echo 'D = $(CURDIR)/debian/tmp' >> ${S}/debian/rules
}

python do_gen_rules() {
    bb.build.exec_func("rules_before_funcs",d)

    import re

    s = d.getVar('S', True)

    dh_fns_name = ["configure","build","install","clean","test"]
    dh_fns = []

    for fn in dh_fns_name:
        func_name = 'dh_' + fn
        func_content = d.getVar(func_name, True) or ''
        # Add a tab at the beginning of each line to avoid syntax error
        func_content = re.sub('^\s*', '\t', func_content)
        func_content = re.sub('\n\s*', '\n\t', func_content)
        func_content = 'override_dh_auto_%s:\n%s\n' % (fn, func_content)
        dh_fns.append(func_content)

    with open(s + "/debian/rules", 'a') as f:
        for fn in dh_fns:
            f.write(fn)
}
addtask gen_rules after do_debianize before do_sbuild

PACKAGES := "${PN}"

python do_package() {
    import textwrap
    from debian.deb822 import Deb822

    s = d.getVar('S', True)
    f = open('%s/debian/control' % s, 'r')
    source = Deb822(f)
    f.close()

    packages = []
    pkgnames = (d.getVar('PACKAGES', True) or "").split()
    for p in pkgnames:
        rdepends = d.getVar('DEB_RDEPENDS_' + p, True) or ''
        architecture = d.getVar('ARCHITECTURE', True) or 'any'
        summary_common = d.getVar('SUMMARY', True) or p
        summary = d.getVar('SUMMARY_' + p, True) or summary_common
        desc_common = d.getVar('DESCRIPTION', True) or ''
        desc = d.getVar('DESCRIPTION_' + p, True) or desc_common

        # Wrap Description
        desc = textwrap.dedent(desc).strip()
        desc = textwrap.fill(desc.strip(), width=74, initial_indent=' ', subsequent_indent=' ')

        pkg = Deb822()
        pkg['Package'] = p
        pkg['Architecture'] = architecture
        pkg['Depends'] = rdepends
        pkg['Description'] = (summary + '\n' + desc).strip()

        packages.append(pkg)

        # Generate debian/*.install
        files = (d.getVar('FILES_' + p, True) or "").split()
        if files:
            with open("%s/debian/%s.install" % (s, p), 'w') as f:
                f.write('\n'.join(files))

    # Generate debian/control
    if packages:
        with open('%s/debian/control' % s, 'w') as f:
            f.write(source.dump())
            for pkg in packages:
                f.write('\n')
                f.write(pkg.dump())
}
addtask package after do_debianize before do_sbuild
