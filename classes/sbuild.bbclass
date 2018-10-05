inherit common

DEPENDS ?= ""
do_sbuild[deptask] = "do_deploy_deb"

apt_repo_init() {
	# TODO: more functional check required
	if [ -d ${APT_REPO_DIR} ]; then
		return
	fi

	bbnote "setting up local apt repository"
	mkdir -p ${APT_REPO_DIR}/conf
	cat << EOF > ${APT_REPO_DIR}/conf/distributions
Codename: ${DEBIAN_CODENAME}
Architectures: ${DEBIAN_ARCH}
Components: main
EOF
	# sbuild requires repository data even if it's empty
	reprepro -b ${APT_REPO_DIR} export
}

do_sbuild[dirs] = "${S}"
do_sbuild () {
	apt_repo_init

	# TODO: sign repo with GPG key?
	sbuild --arch ${DEBIAN_ARCH} -d ${DEBIAN_CODENAME} \
		--extra-repository="deb [ allow-insecure=yes ] file:///build/repo buster main"
}
addtask sbuild after do_unpack_srcpkg before deploy_deb

do_deploy_deb[dirs] = "${WORKDIR}"
do_deploy_deb() {
	reprepro -b ${APT_REPO_DIR} includedeb ${DEBIAN_CODENAME} ${WORKDIR}/*.deb
}
addtask deploy_deb after do_sbuild before do_build
