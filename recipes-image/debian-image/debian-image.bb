#
# A sample of image generator only using debootstrap
#
# NOTE: sudo is temporally used, so NOPASSWD required in sudoers
# TODO: Support multiarch packages and cross image generation
#

# packages in non local apt repositories (Debian mirrors)
DEB_RDEPENDS = "openssh-server"

# packages in the local apt repository provided by individual recipes
RDEPENDS = "hello foo"
do_rootfs[rdeptask] = "do_deploy_deb"

# TODO: If multiple repositories provide the same package,
# the highest version is selected even if the local repository
# includes the package that user intentionally customized.
INSTALL_PKGS = "${DEB_RDEPENDS} ${RDEPENDS}"

ROOTFS = "${WORKDIR}/rootfs"

ROOTFS_APT_REPO_DIR = "/apt"
ROOTFS_SOURCES_LIST = "/etc/apt/sources.list.d/local.list"

SUDO = "sudo -E http_proxy=${http_proxy}"
CHROOT = "${SUDO} chroot ${ROOTFS}"

# TODO: drop root privilege using fakeroot/fakechroot
do_build() {
	if [ -d ${ROOTFS} ]; then
		bbnote "Cleaning old rootfs directory"
		${SUDO} rm -r ${ROOTFS}
	fi
	bbnote "Running debootstrap"
	${SUDO} debootstrap ${DEBIAN_CODENAME} ${ROOTFS} ${DEBIAN_REPO}

	bbnote "Copying local apt repository to rootfs"
	${SUDO} cp -r ${APT_REPO_DIR} ${ROOTFS}/${ROOTFS_APT_REPO_DIR}
	# TODO: create Release file (now ignored by trusted=yes)
	bbnote "Registering local apt repository to apt in rootfs"
	${CHROOT} sh -c "echo \"deb [trusted=yes] file://${ROOTFS_APT_REPO_DIR} ${DEBIAN_CODENAME} main\" \
		> ${ROOTFS_SOURCES_LIST}"
	${CHROOT} apt update

	bbnote "Upgrading packages available in local apt repository"
	${CHROOT} apt full-upgrade -y

	bbnote "Installing required packages"
	${CHROOT} apt install -y ${INSTALL_PKGS}

	# TODO: Run postinst commands, and generate the final rootfs image (ext4, tarball, etc.)
}
