#!/bin/sh

DEP_PKGS="python3 sbuild dh-make reprepro"

warn() {
	echo "WARNING: ${@}"
}

die() {
	echo "ERROR: ${@}"
	exit 1
}

if [ "$(whoami)" != "root" ]; then
	die "Please run this script as root"
fi

if [ ! -r /etc/os-release ]; then
	warn "/etc/os-release not found, failed to check the host distro"
fi
OS_ID=$(grep "^ID=" /etc/os-release | sed "s@^ID=\(.*\)@\1@")
if [ "${OS_ID}" != "debian" ]; then
	warn "\"${OS_ID}\" is not a tested distro, \
some dependencies might not be satisfied"
fi

apt-get install ${DEP_PKGS} || die "failed to install dependent packages"
