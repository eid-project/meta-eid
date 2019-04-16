inherit raw-build

PV = "v4.19.13-cip1"
SRCREV = "c312fd1d432e36f9012127fe3c1d2b7023afae48"

SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/cip/linux-cip.git;;branch=linux-4.19.y-cip;protocol=https"

DEB_DEPENDS += "bison flex libelf-dev bc libssl-dev"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

LINUX_DEFCONFIG ?= ""
LINUX_DEFCONFIG_qemux86-64 ?= "${S}/arch/x86/configs/x86_64_defconfig"
LINUX_DEFCONFIG_qemuarm ?= "${S}/arch/arm/configs/vexpress_defconfig"

LINUX_CONFIG ?= ""

# TODO: consider adding LOADADDR=${LOADADDR}, V=${V}
OPTS = " \
	-C ${S} \
	O=${B} \
	ARCH=${ARCH} \
	CROSS_COMPILE=${CROSS_COMPILE} \
"

do_raw_build() {
	# cleanup build directory
	rm -rf ${B}
	mkdir -p ${B}

	# setup config
	# TODO: use merge_config in OE-Core
	bbnote "LINUX_DEFCONFIG: ${LINUX_DEFCONFIG}"
	bbnote "LINUX_CONFIG: ${LINUX_CONFIG}"
	cat ${LINUX_DEFCONFIG} ${LINUX_CONFIG} > ${B}/.config
	${SCH} make ${OPTS} oldconfig

	# build
	# TODO: use PARALLEL_MAKE
	${SCH} make -j8 ${OPTS}

	# install
	install -d ${D}/boot
	${SCH} make ${OPTS} INSTALL_PATH=${D}/boot install
	${SCH} make ${OPTS} INSTALL_MOD_PATH=${D} modules_install

	# deploy
	install -d ${DEPLOY_DIR}/raw
	cd ${D}
	tar czf ${DEPLOY_DIR}/raw/${P}.tar.gz .
}
