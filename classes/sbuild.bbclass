inherit common

DEPENDS ?= ""
do_sbuild[deptask] = "do_deploy_deb"

apt_repo_init() {
	# TODO: more functional check required
	if [ -d ${APT_REPO_DIR}/conf/distributions ]; then
		return
	fi

	bbnote "setting up local apt repository"
	mkdir -p ${APT_REPO_DIR}/conf
	cat << EOF > ${APT_REPO_DIR}/conf/distributions
Codename: ${DEBIAN_CODENAME}
Architectures: ${DEB_HOST_ARCH}
Components: main
EOF
	# sbuild requires repository data even if it's empty
	reprepro -b ${APT_REPO_DIR} export
}

apt_repo_rm() {
	DEBS=$(ls ${DEB_DIR} 2> /dev/null | sed "s@_.*@@")
	if [ -z "${DEBS}" ]; then
		return
	fi
	reprepro -b ${APT_REPO_DIR} remove ${DEBIAN_CODENAME} ${DEBS}
}

# FIXME: doesn't work as long as CLEANFUNCS execution code is
# moved before removing ${WORKDIR} in do_clean. See e78850dc in Isar.
CLEANFUNCS += "apt_repo_rm"

EXTRA_SBUILDCONF ??= ""

do_sbuild[dirs] = "${S}"
do_sbuild () {
	rm -rf ${DEB_DIR}

	apt_repo_init

	# TODO: sign repo with GPG key?
	sbuild --host=${DEB_HOST_ARCH} \
	       --build=${DEB_BUILD_ARCH} \
	       -d ${DEBIAN_CODENAME} \
	       -c ${CHROOT_NAME} \
	       --extra-repository="deb [ allow-insecure=yes trusted=yes ] file:///repo buster main" \
	       ${EXTRA_SBUILDCONF}

	install -d ${DEB_DIR}
	for deb in ${S}/../*.deb; do
		mv ${deb} ${DEB_DIR}
	done
}
addtask sbuild after do_unpack_srcpkg before deploy_deb

do_deploy_deb[dirs] = "${WORKDIR}"
do_deploy_deb() {
	apt_repo_rm ${DEB_DIR}/*.deb
	reprepro -b ${APT_REPO_DIR} includedeb ${DEBIAN_CODENAME} ${DEB_DIR}/*.deb
}
addtask deploy_deb after do_sbuild before do_build
