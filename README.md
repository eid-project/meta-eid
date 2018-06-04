meta-eid
========

meta-eid provides the minimal configurations, classes, and recipes
for bitbake to build Debian packages or other extra sources.

This layer is just a working repository for finding better build
infrastructure to build Debian packages with bitbake.

How to use
==========

Setup build environment.

    $ git clone git://git.yoctoproject.org/poky.git
    $ cd poky
    $ git clone https://github.com/zuka0828/meta-eid.git
    $ cd ..
    $ ./poky/meta-eid/scripts/install-deps.sh
    $ source ./poky/meta-eid/setup.sh

Build extra sources.

    $ bitbake hello localfiles

Build rootfs image.

    $ bitbake debian-image
