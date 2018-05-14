# class file for non-Debian sources

#
# basic varibales, should be defined in another file??
#

D = "${WORKDIR}/image"

bindir = "/usr/bin"
libdir = ""
sysconfdir = "/etc"

# Path prefixes
export base_prefix = ""
export prefix = "/usr"
export exec_prefix = "${prefix}"

# Base paths
export base_bindir = "${base_prefix}/bin"
export base_sbindir = "${base_prefix}/sbin"
export base_libdir = "${base_prefix}/${baselib}"
export nonarch_base_libdir = "${base_prefix}/lib"

# Architecture independent paths
export sysconfdir = "${base_prefix}/etc"
export servicedir = "${base_prefix}/srv"
export sharedstatedir = "${base_prefix}/com"
export localstatedir = "${base_prefix}/var"
export datadir = "${prefix}/share"
export infodir = "${datadir}/info"
export mandir = "${datadir}/man"
export docdir = "${datadir}/doc"
export systemd_unitdir = "${nonarch_base_libdir}/systemd"
export systemd_system_unitdir = "${nonarch_base_libdir}/systemd/system"
export nonarch_libdir = "${exec_prefix}/lib"
export systemd_user_unitdir = "${nonarch_libdir}/systemd/user"

# Architecture dependent paths
export bindir = "${exec_prefix}/bin"
export sbindir = "${exec_prefix}/sbin"
export libdir = "${exec_prefix}/${baselib}"
export libexecdir = "${exec_prefix}/libexec"
export includedir = "${exec_prefix}/include"
export oldincludedir = "${exec_prefix}/include"
localedir = "${libdir}/locale"


#
# do_fetch, do_unpack: copied from base.bbclass in OE-Core and modified
# do_clean: copied from utility-tasks.bbclass in OE-Core
#

do_fetch[dirs] = "${DL_DIR}"
python do_fetch() {

    src_uri = (d.getVar('SRC_URI') or "").split()
    if len(src_uri) == 0:
        return

    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.download()
    except bb.fetch2.BBFetchException as e:
        bb.fatal(str(e))
}
addtask fetch before do_build

do_unpack[dirs] = "${WORKDIR}"
python do_unpack() {
    src_uri = (d.getVar('SRC_URI') or "").split()
    if len(src_uri) == 0:
        return

    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.unpack(d.getVar('WORKDIR'))
    except bb.fetch2.BBFetchException as e:
        bb.fatal(str(e))
}
addtask unpack after do_fetch before do_build

CLEANFUNCS ?= ""

# replace oe.path.remove() by subprocess.call()
addtask clean
do_clean[nostamp] = "1"
python do_clean() {
    import subprocess

    """clear the build and temp directories"""
    dir = d.expand("${WORKDIR}")
    bb.note("Removing " + dir)
    subprocess.call('rm -rf ' + dir, shell=True)

    dir = "%s.*" % d.getVar('STAMP')
    bb.note("Removing " + dir)
    subprocess.call('rm -rf ' + dir, shell=True)

    for f in (d.getVar('CLEANFUNCS') or '').split():
        bb.build.exec_func(f, d)
}
