#!/bin/sh

# assumes to be called in the build directory
LOCALCONF=$(pwd)/conf/local.conf
CHROOT_DIR=$(pwd)/chroot

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
for var in DEBIAN_CODENAME DEBIAN_ARCH DEBIAN_REPOS; do
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
sbuild-createchroot \
	--chroot-suffix="-eid" \
	${DEBIAN_CODENAME} \
	${CHROOT_DIR}/${DEBIAN_CODENAME}-${DEBIAN_ARCH} \
	${DEBIAN_REPOS} \
	|| die "sbuild-createchroot failed"
