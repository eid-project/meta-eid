inherit common

DEPENDS ?= ""
do_sbuild[deptask] = "do_deploy_deb"

do_sbuild[dirs] = "${S}"
do_sbuild () {
	sbuild --arch ${DEBIAN_ARCH} -d ${DEBIAN_CODENAME}
}
addtask sbuild after do_unpack_srcpkg before deploy_deb

do_deploy_deb[dirs] = "${WORKDIR}"
do_deploy_deb() {
	if [ ! -d ${APT_REPO_DIR} ]; then
		bbnote "initializing local apt repository"
		mkdir -p ${APT_REPO_DIR}/conf
		cat << EOF > ${APT_REPO_DIR}/conf/distributions
Codename: ${DEBIAN_CODENAME}
Architectures: ${DEBIAN_ARCH}
Components: main
EOF
	fi
	reprepro -b ${APT_REPO_DIR} includedeb ${DEBIAN_CODENAME} ${WORKDIR}/*.deb
}
addtask deploy_deb after do_sbuild before do_build
