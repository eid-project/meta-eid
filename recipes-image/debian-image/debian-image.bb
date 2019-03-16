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

ROOTFS_STRAP_TOOL ?= "debootstrap"

rootfs_debootstrap() {
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
}

# TODO: need to apply the patch multistrap.patch to /usr/sbin/multistrap
MULTISTRAP_CONF = "${WORKDIR}/multistrap.conf"
rootfs_multistrap() {
	cat <<EOF > ${MULTISTRAP_CONF}
# based on the example in multistrap --help

[General]
arch=amd64
directory=${ROOTFS}
# same as --tidy-up option if set to true
cleanup=true
# same as --no-auth option if set to true
# keyring packages listed in each bootstrap will
# still be installed.
noauth=true
# extract all downloaded archives (default is true)
unpack=true
# enable MultiArch for the specified architectures
# default is empty
multiarch=
# aptsources is a list of sections to be used for downloading packages
# and lists and placed in the /etc/apt/sources.list.d/multistrap.sources.list
# of the target. Order is not important
aptsources=Debian local
# the order of sections is not important.
# the bootstrap option determines which repository
# is used to calculate the list of Priority: required packages.
bootstrap=Debian local

[Debian]
packages=
source=${DEBIAN_REPO}
#keyring=debian-archive-keyring
suite=${DEBIAN_CODENAME}

[local]
packages=
source=file://${APT_REPO_DIR}
#keyring=
suite=${DEBIAN_CODENAME}
EOF

	multistrap -f ${MULTISTRAP_CONF}
}

# TODO: drop root privilege using fakeroot/fakechroot
do_rootfs[dirs] = "${WORKDIR}"
do_rootfs() {
	if [ -d ${ROOTFS} ]; then
		bbnote "Cleaning old rootfs directory"
		${SUDO} rm -r ${ROOTFS}
	fi

	case "${ROOTFS_STRAP_TOOL}" in
		"debootstrap") rootfs_debootstrap ;;
		"multistrap") rootfs_multistrap ;;
		"") bbfatal "ROOTFS_STRAP_TOOL not defined" ;;
		*) bbfatal "unrecognized ROOTFS_STRAP_TOOL: ${ROOTFS_STRAP_TOOL}" ;;
	esac

	# TODO: Run postinst commands, and generate the final rootfs image (ext4, tarball, etc.)
}
addtask rootfs before do_build
