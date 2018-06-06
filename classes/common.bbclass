# Common variables and functions shared by recipes-debian and recipes-app

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
