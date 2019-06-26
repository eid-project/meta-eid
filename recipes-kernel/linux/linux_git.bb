inherit debianize

SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/cip/linux-cip.git;protocol=https;branch=linux-4.19.y-cip"

SRCREV = "linux-4.19.y-cip"
PV = "4.19"
S = "${WORKDIR}/git"

DEB_DEPENDS = "bc bison flex libelf-dev libssl-dev:native"

LINUX_DEFCONFIG_amd64 = "x86_64_defconfig"
LINUX_DEFCONFIG_armhf = "multi_v7_defconfig"

KERNEL_SRCARCH_amd64 = "x86"
KERNEL_SRCARCH_armhf = "arm"
ARCH_amd64 = "x86_64"
ARCH_armhf = "arm"

dh_configure(){
	cp arch/${KERNEL_SRCARCH}/configs/${LINUX_DEFCONFIG} .config
	ARCH=${ARCH} make olddefconfig
}

dh_build() {
	ARCH=${ARCH} make CROSS_COMPILE=${CROSS_COMPILE}
}

dh_install() {
	mkdir -p ${D}/boot
	ARCH=${ARCH} make install INSTALL_PATH=${D}/boot
	ARCH=${ARCH} make modules_install INSTALL_MOD_PATH=${D}
}

dh_clean() {
	# do nothing
}

rules_before_funcs_append() {
	cat >> ${S}/debian/rules << EOF
ifneq (\$(DEB_BUILD_GNU_TYPE),\$(DEB_HOST_GNU_TYPE))
export CROSS_COMPILE ?= \$(DEB_HOST_GNU_TYPE)-
endif
EOF
}

PACKAGES = "kernel-modules kernel-image"
FILES_kernel-modules = "/lib/modules"
FILES_kernel-image = "/boot"
