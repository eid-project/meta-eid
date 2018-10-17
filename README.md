meta-eid
========

meta-eid provides the minimal configurations, classes, and recipes
for bitbake to build Debian packages or other extra sources.

This layer is just a working repository for finding better build
infrastructure to build Debian packages with bitbake.

System Requirements
===================

meta-eid is now developed and tested on the following environment.

* Build environment: Debian GNU/Linux 10 buster
* Poky version: Yocto Project 2.6 thud
* Architecture(DEBIAN_ARCH): amd64

How to use
==========

Download build tools.

    $ git clone git://git.yoctoproject.org/poky.git
    $ cd poky
    $ git clone https://github.com/zuka0828/meta-eid.git
    $ cd ..
    $ sudo ./poky/meta-eid/scripts/install-deps.sh

Register myself to sbuild user

    $ sudo sbuild-adduser $(whoami)

Setup build directory.

    $ source ./poky/meta-eid/setup.sh
    $ sudo ../poky/meta-eid/scripts/setup-sbuild.sh

(Optional) Add proxy setting into the schroot.
Please replace `http://your.proxy.server:1234` below.

    $ sudo sbuild-shell buster-amd64-eid
    (chroot) # echo 'acquire::http::proxy "http://your.proxy.server:1234";' >> /etc/apt/apt.conf.d/proxy
    (chroot) # exit

Build Debian source package.

    $ bitbake hello

Build non-Debianized source.
This is the simplest recipe to build non-Debianized source.

    $ bitbake localfiles

Build non-Debianized source.
This recipe fetches source code from remote, and has
build & run-time dependencies on Debian packages and non-Debian package `baz`.

    $ bitbake foo
