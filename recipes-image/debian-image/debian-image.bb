# provided by debian-repo.bb
RDEPENDS_DEBIAN = "openssh-server"

# provided by individual recipes
RDEPENDS_EXTRA = ""

RDEPENDS = "${RDEPENDS_DEBIAN} ${RDEPENDS_EXTRA}"

ROOTFS = "${WORKDIR}/rootfs"

# TODO: drop root privilege using fakeroot/fakechroot
do_build() {
	bbnote "Running debootstrap"
	sudo debootstrap ${DEBIAN_CODENAME} ${ROOTFS} ${DEBIAN_REPOS}

	bbnote "Installing required packages"
	sudo chroot ${ROOTFS} apt-get update
	sudo chroot ${ROOTFS} apt-get install -y ${RDEPENDS}
}
