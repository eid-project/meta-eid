inherit debianize

SRC_URI = "git://git.denx.de/u-boot.git;protocol=http"

SRCREV = "v2019.01"
PV = "2019.01"
S = "${WORKDIR}/git"
B = "debian/build"

DEB_DEPENDS = "bc bison flex libpython-dev:native python:any swig"

UBOOT_MACHINE_amd64 ?= "qemu-x86_64_defconfig"
UBOOT_MACHINE_armhf ?= "qemu_arm_defconfig"

dh_configure(){
	$(MAKE) -- O=${B} ${UBOOT_MACHINE}
}

EXTRA_DHBUILD = "O=${B} CROSS_COMPILE=${CROSS_COMPILE}"

dh_install() {
	mkdir -p ${D}
	cp ${B}/u-boot.bin ${D}/
}

rules_before_funcs_append() {
	cat >> ${S}/debian/rules << EOF
ifneq (\$(DEB_BUILD_GNU_TYPE),\$(DEB_HOST_GNU_TYPE))
export CROSS_COMPILE ?= \$(DEB_HOST_GNU_TYPE)-
endif
EOF
}

FILES_${PN} = "/u-boot.bin"
