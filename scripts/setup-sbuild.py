#!/usr/bin/env python3

import sys
import os

# Add bitbake/lib to syspath so we can import bb modules.
# Base on poky/scripts/lib/scriptpath.py
def add_bitbake_lib_path():
    basepath = os.path.abspath(os.path.dirname(__file__) + '/../..')
    bitbakepath = None
    if os.path.exists(basepath + '/bitbake/lib/bb'):
        bitbakepath = basepath + '/bitbake'
    else:
        # look for bitbake/bin dir in PATH
        for pth in os.environ['PATH'].split(':'):
            if os.path.exists(os.path.join(pth, '../lib/bb')):
                bitbakepath = os.path.abspath(os.path.join(pth, '..'))
                break

    if bitbakepath:
        sys.path.insert(0, bitbakepath + '/lib')

    return bitbakepath


# tinfoil to get bitbake variables
def tinfoil_init():
    import bb.tinfoil
    tinfoil = bb.tinfoil.Tinfoil()
    tinfoil.prepare(True)
    return tinfoil


# Display error message and exit
def die(msg):
    RED = '\033[91m'
    BLD_RED = '\033[1;91m'
    RST = '\033[0m'
    msg = "".join([BLD_RED, 'ERROR', RST, RED, ': ', msg])
    sys.exit(msg)


def main():
    if os.geteuid() != 0:
        die("Please run this script as root.")

    bitbake_lib_path = add_bitbake_lib_path()
    if not bitbake_lib_path:
        die('Bitbake lib path not found.')

    import subprocess
    tinfoil = tinfoil_init()

    chroot_suffix = tinfoil.config_data.getVar('CHROOT_SUFFIX')
    chroot_dir = tinfoil.config_data.getVar('CHROOT_DIR')
    deb_build_arch = tinfoil.config_data.getVar('DEB_BUILD_ARCH')
    debian_codename = tinfoil.config_data.getVar('DEBIAN_CODENAME')
    debian_repo = tinfoil.config_data.getVar('DEBIAN_REPO')

    # Create chroot
    # TODO: define schroot name particular to each build directory
    # to avoid creating duplicated schroot in one system,
    # or use --chroot-mode=unshare?
    cmd = ['sbuild-createchroot']
    if deb_build_arch:
        cmd.append('--arch=%s' % deb_build_arch)
    if chroot_suffix:
        cmd.append('--chroot-suffix=%s' % chroot_suffix)
    cmd.append(debian_codename)
    cmd.append(chroot_dir)
    cmd.append(debian_repo)
    err = subprocess.call(cmd)
    if err != 0:
        die('Failed to create chroot.')

    # automatically put HTTP proxy setting for apt into the schroot
    http_proxy = os.getenv('http_proxy') or os.getenv('HTTP_PROXY')
    if http_proxy:
        conf_file = os.path.join(chroot_dir,'etc/apt/apt.conf.d/proxy')
        conf_content = 'Acquire::http::Proxy "%s";' % http_proxy
        f = open(conf_file, 'w')
        f.write(conf_content)
        f.close()

    # TODO: any other better places where
    # the script doesn't need to care the permission?
    apt_repo_dir = tinfoil.config_data.getVar('APT_REPO_DIR')
    subprocess.call(['mkdir', '-p', apt_repo_dir])
    subprocess.call(['chmod', '777', apt_repo_dir])

    # Because this script is run as root, bitbake-cookerdaemon.log and
    # ./tmp directory are created as root.
    # Change their owner to same as the owner of build directory.
    topdir = tinfoil.config_data.getVar('TOPDIR')
    tmpdir = tinfoil.config_data.getVar('TMPDIR')
    subprocess.call(['chown', '-R', '--reference=%s' % topdir,
                     '%s/bitbake-cookerdaemon.log' % topdir, tmpdir])


if __name__ == "__main__":
    main()
