Setup
=====

Simplify sbuild setup
---------------------

* sbuild requires root priviledge and it keeps schroot config
  in the global place (/etc/schroot/chroot.d/*)
* Remove sudo (if possible)
* Rmmove or move the schroot config to build directory
  (need to change --variant of sbuild-createchroot)
* Fix destroychroot (required?)

Cross-building
==============

Support cross-building applications
-----------------------------------

* Cross-building the following recipes fails when `DEB_HOST_ARCH = armhf`
    * `hello`, `foo`, `bar`
* Error in `dh_shlibdeps` (`debian/rules binary`):

```
dpkg-shlibdeps: error: canno find library libc.so.6 needed by debian/hello/usr/bin/hello (ELF format: 'elf32-littlearm' abi: '0101002800000000'; RPATH: '')
dpkg-shlibdeps: error: canno find library ld-linux-armhf.so.3 needed by debian/hello/usr/bin/hello (ELF format: 'elf32-littlearm' abi: '0101002800000000'; RPATH: '')
dpkg-shlibdeps: error: cannot continue due to the errors listed above
```

Image generation for foreign architectures
------------------------------------------

* `bitbake debian-image` has not been tested with `DEB_HOST_ARCH != DEB_BUILD_ARCH`

Building Non-Debianized sources
===============================

* At least, recipes for the following targets should be implemented
    * Kernel, U-Boot, sample pplication

Image generation
================

Generating ready-to-use image
-----------------------------

* `debian-image` doesn't support generating ready-to-use image like
  ext4 image, SD card image, etc.
* Consider reusing existing image generation tools like debos

Testing
=======

Testing on QEMU
---------------

* At least, the following architectures should be tested with QEMU
    * x86 64bit, ARM 32bit/64bit

Build time
==========

Optimize packages in schroot
----------------------------

* Only the default packages (fakeroot, build-essential) are installed now
* Consider to install the following packages by default
    * lintian dependencies
    * cross-toolchain

debootstrap too slow
--------------------

* eatmydata in schroot configuration doesn't improve debootstrapping time
  in `sbuild-createchroot` and `do_rootfs`

Parallel sbuild
---------------

* sbuild seems exclusive; parallel sbuilds return the following message:

```
Another sbuild process (job ...) is currently using the build chroot; waiting...
```
