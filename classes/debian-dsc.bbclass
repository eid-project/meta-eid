# Original source:
# https://github.com/alexbluesman/bitbake-dsc/blob/master/meta/classes/debian-dsc.bbclass
# Copyright (C) 2018 Alexander Smirnov

python __anonymous() {
    # Parse DSC_URI and its checksums
    dsc_uri = (d.getVar("DSC_URI", True) or "").split()
    if len(dsc_uri) == 0:
        bb.fatal("DSC_URI not set")
    elif len(dsc_uri) > 1:
        bb.fatal("more than two values set in DSC_URI")
    # TODO: it would be better if the values of d.getVarFlag("DSC_URI", "*sum")
    # are passed to bb.fetch2.Fetch() automatically

    # Fetch .dsc package file
    try:
        fetcher = bb.fetch2.Fetch(dsc_uri, d)
        fetcher.download()
    except bb.fetch2.BBFetchException as e:
        raise bb.build.FuncFailed(e)

    # Open .dsc file from downloads
    dl_dir = d.getVar('DL_DIR', True) or ""
    dsc_file = (dsc_uri[0].split(";")[0]).split("/")[-1]
    filepath = dl_dir + '/' + dsc_file
    repo = (dsc_uri[0].split(";")[0]).replace(dsc_file, "")
    files = []

    # Parse .dsc for the important fields
    # TODO: Parse checksums of all files here and pass them to SRCPKG_URI
    with open(filepath, 'r') as file:
        line = file.readline()
        while line:
            # Get package version and export PV
            if line.startswith('Version:'):
                pv = line.split(": ")[-1].rstrip()
                d.setVar('PV', pv)
            elif line.startswith('Files:'):
                line = file.readline()
                while line and line.startswith(' '):
                    f = line.split()[2]
                    files.append(repo + f)
                    line = file.readline()
                break
            line = file.readline()
        file.close()

    d.setVar('SRCPKG_URI', ' '.join(files))

# TODO:
# 1. Get the name of tarball and set SRC_URI (lightweight dsc backend) => Done
# 2. Fetch tarball and derive 'debian/control' (full dsc backend)
# 3. Extract fetched tarball and setup source tree
}

# remove the unneeded default value
SRC_URI = ""

# only fetch source package files in SRCPKG_URI separately from SRC_URI
# so that do_unpack_srcpkg can simply unpack the source package
python do_fetch_srcpkg() {
    srcpkg_uri = (d.getVar('SRCPKG_URI', True) or '').split()
    if len(srcpkg_uri) == 0:
        return
    try:
        fetcher = bb.fetch2.Fetch(srcpkg_uri, d)
        fetcher.download()
    except bb.fetch2.BBFetchException as e:
        raise bb.build.FuncFailed(e)
}
addtask fetch_srcpkg after do_fetch before do_unpack

do_unpack_srcpkg[dirs] = "${WORKDIR}"
do_unpack_srcpkg() {
	dpkg-source -x ${DL_DIR}/${PN}_${PV}.dsc ${S}
}
addtask unpack_srcpkg after do_unpack before do_build
