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
for var in DEBIAN_CODENAME DEBIAN_REPO; do
	val=$(grep "${var}\s*=" ${LOCALCONF} | tail -1 | \
	      sed "s@${var}\s*=\s*\(.*\)@\1@")
	if [ -z "${val}" ]; then
		die "${var} is not defined in ${LOCALCONF}"
	fi
	eval ${var}=${val}
done

DEB_BUILD_ARCH=`dpkg --print-architecture`
# define schroot name particular to each build directory because
# schroot doesn't permit to create duplicated named chroot in a system
CHROOT_SUFFIX="-$(pwd | md5sum | cut -c 1-8)"
CHROOT_NAME="${DEBIAN_CODENAME}-${DEB_BUILD_ARCH}${CHROOT_SUFFIX}"
sbuild-createchroot \
	--arch=${DEB_BUILD_ARCH} \
	--chroot-suffix="${CHROOT_SUFFIX}" \
	--include=eatmydata \
	--command-prefix=eatmydata \
	${DEBIAN_CODENAME} \
	${CHROOT_BASE_DIR}/${CHROOT_NAME} \
	${DEBIAN_REPO} \
	|| die "sbuild-createchroot failed"

# /home directory needs to be bind mounted in schroot so that
# the raw-build recipes requires WORKDIR.
# Need to create the custom schroot profile here based on "sbuild" because
# there is no option provided by sbuild-createchroot to
# use specific schroot profile created by generic users.
if [ ! -d /etc/schroot/eid ]; then
	cp -a /etc/schroot/sbuild /etc/schroot/eid || \
		die "failed to copy schroot sbuild profile"
	echo "/home /home none rw,bind 0 0" >> /etc/schroot/eid/fstab || \
		die "failed to append /home bind mount setting"
fi

# schroot profile cannot be overwritten by "-o profile=xxx", so
# need to overwrite the profile value defined in the default config.
# Also, the path "/etc/schroot/chroot.d" is hard coded in schroot, so
# there is no way to use custom configs created by generic users.
sed -i "s@^profile=sbuild@profile=eid@" /etc/schroot/chroot.d/${CHROOT_NAME}-*

if ! schroot -c ${CHROOT_NAME} -i > /dev/null; then
	die "chroot ${CHROOT_NAME} is not correctly created"
fi

# tell sbuild information to bitbake
cat <<EOF > ${CHROOT_BASE_DIR}/sbuild.conf || \
	die "failed to generate sbuild.conf"
# exported by setup-sbuild.sh
CHROOT_SUFFIX = "${CHROOT_SUFFIX}"
CHROOT_NAME = "${CHROOT_NAME}"
CHROOT_DIR = "${CHROOT_BASE_DIR}/${CHROOT_NAME}"
EOF

# TODO: any other better places where
# the script doesn't need to care the permission?
APT_REPO_DIR=${CHROOT_BASE_DIR}/${CHROOT_NAME}/repo
mkdir -p ${APT_REPO_DIR}
chmod 777 ${APT_REPO_DIR}

# automatically put HTTP proxy setting for apt into the schroot
if [ -n "${http_proxy}" ]; then
	sh -c "echo 'acquire::http::proxy \"${http_proxy}\";' > \
		${CHROOT_BASE_DIR}/${CHROOT_NAME}/etc/apt/apt.conf.d/proxy"
fi
