inherit apt

# overwritten by the anonymous function
PACKAGES = ""

def get_pkglist_from_repo(d):
    import subprocess

    bb.note('Running apt-get update')
    bb.build.exec_func('apt_update', d)

    apt_opts = d.getVar('APT_OPTS')
    bb.note('Running apt-cache pkgnames')
    pkgnames = subprocess.getoutput('apt-cache ' + apt_opts + ' pkgnames | sort')
    return pkgnames.replace('\n', ' ')

# Always executed at parse time.
# The purpose of this function is to set PACKAGES to available
# Debian package list in APT_REPOS.
# FIXME: Calling bb.build.exec_func() or subprocess.call()
#        from the second parse hangs. Temporally use bitbake's
#        persist_data functions to keep the first result
python __anonymous() {
    debian_persist = bb.persist_data.persist('DEBIAN', d)

    if debian_persist.has_key('pkglist'):
        bb.note('Restoring pkglist')
        pkglist = debian_persist.__getitem__('pkglist')
    else:
        bb.note('Initializing pkglist')
        pkglist = get_pkglist_from_repo(d)
        debian_persist.__setitem__('pkglist', pkglist)
    d.setVar('PACKAGES', pkglist)
}

do_build() {
	bbnote "${PN} has nothing to do for do_build"
	bbnote "Available PACKAGES generated from the repositories:"
	bbnote "${PACKAGES}"
}

addtask do_clean
do_clean[nostamp] = "1"
python do_clean() {
    debian_persist = bb.persist_data.persist('DEBIAN', d)

    if debian_persist.has_key('pkglist'):
        bb.note('Deleting pkglist')
        pkglist = debian_persist.__delitem__('pkglist')
}
