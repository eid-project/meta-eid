#!/bin/sh

# assumes to be called in the build directory
LOCALCONF=$(pwd)/conf/local.conf
CHROOT_BASE_DIR=$(pwd)/chroot

die() {
	echo "ERROR: ${@}"
	exit 1
}

if [ "$(whoami)" != "root" ]; then
	die "Please run this script as root"
fi

if [ ! -f ${LOCALCONF} ]; then
	die "${LOCALCONF} not found"
fi

# pull variables defined in LOCALCONF
for var in DEBIAN_CODENAME DEBIAN_ARCH DEBIAN_REPO; do
	val=$(grep "${var}\s*=" ${LOCALCONF} | tail -1 | \
	      sed "s@${var}\s*=\s*\(.*\)@\1@")
	if [ -z "${val}" ]; then
		die "${var} is not defined in ${LOCALCONF}"
	fi
	eval ${var}=${val}
done

# TODO: define schroot name particular to each build directory
# to avoid creating duplicated schroot in one system,
# or use --chroot-mode=unshare?
CHROOT_SUFFIX="-eid"
CHROOT_NAME="${DEBIAN_CODENAME}-${DEBIAN_ARCH}${CHROOT_SUFFIX}"
sbuild-createchroot \
	--chroot-suffix="${CHROOT_SUFFIX}" \
	${DEBIAN_CODENAME} \
	${CHROOT_BASE_DIR}/${CHROOT_NAME} \
	${DEBIAN_REPO} \
	|| die "sbuild-createchroot failed"

if ! schroot -c ${CHROOT_NAME} -i > /dev/null; then
	die "chroot ${CHROOT_NAME} is not correctly created"
fi

# TODO: any other better places where
# the script doesn't need to care the permission?
APT_REPO_DIR=${CHROOT_BASE_DIR}/${CHROOT_NAME}/repo
mkdir -p ${APT_REPO_DIR}
chmod 777 ${APT_REPO_DIR}
