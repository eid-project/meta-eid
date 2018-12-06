[![Build Status](https://travis-ci.org/eid-project/meta-eid.svg?branch=master)](https://travis-ci.org/eid-project/meta-eid)

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

meta-eid can be used in a docker container. This is the easiest way
to ensure running in a validated environment.

Another option is to run meta-eid directly on a Linux machine. Debian
is recommended. It is called [native method](#native).

Docker
------

Ensure that docker is installed on your machine.

If http\_proxy, etc. is set as environment on your terminal it is
redirected into the docker container.

To build, start and change into the container:

    $ git clone https://git.yoctoproject.org/git/poky.git
    $ cd poky
    $ git clone https://github.com/eid-project/meta-eid.git
    $ cd meta-eid
    $ make
    (docker) $ source ./poky/meta-eid/setup.sh

Some cleanup is needed since container pulled from Dockerhub contain
previous build artifacts.

    (docker) $ sudo rm -rf chroot
    (docker) $ sudo rm -rf /etc/schroot/chroot.d/*
    (docker) $ sudo ../poky/meta-eid/scripts/setup-sbuild.sh

Now you can continue with [build examples](#build-examples).

# Commit changes in made in container

Remember, containers are stateless.
If you leave the container all changes inside the container are lost.
To avoid this, use the following command on a second terminal:

    $ docker commit eid eid-image:mysnapshot

To start this snapshot:

    $ IMAGENAME=eid-image:mysnapshot make

Native
------

Download build tools.

    $ git clone https://git.yoctoproject.org/git/poky.git
    $ cd poky
    $ git clone https://github.com/eid-project/meta-eid.git
    $ cd ..
    $ sudo ./poky/meta-eid/scripts/install-deps.sh

Register myself to sbuild user

    $ sudo sbuild-adduser $(whoami)

Continue with 'Setup Build Directory'.

Setup build directory
---------------------

Run the setup script.

    $ source ./poky/meta-eid/setup.sh

If this is the first time to run this script,
a new build directory `build` is created and
you need to do the steps in 'Setup sbuild'.

If `build` already exists (not the first time to run),
the existing directory will be reused for the next build and
you can skip 'Setup sbuild' and continue with 'Build Examples'.

Setup sbuild
------------

NOTE: The following steps can be ignore if you've already done.

Create a schroot into `build` based on the configuration in the `build`.

    $ sudo ../poky/meta-eid/scripts/setup-sbuild.sh

This script creates a sbuild directory named
`build/chroot/${DEBIAN_CODENAME}-${DEBIAN_ARCH}-eid`.
(`${DEBIAN_CODENAME}` and `${DEBIAN_ARCH}` is defined in `build/local.conf`)

(Optional) Add proxy setting into the schroot if you need.
Please replace `http://your.proxy.server:1234` below to your proxy server.

    $ sudo sh -c "echo 'acquire::http::proxy \"http://your.proxy.server:1234\";' \
      > chroot/${DEBIAN_CODENAME}-${DEBIAN_ARCH}-eid/etc/apt/apt.conf.d/proxy"

Continue with 'Build Examples'.

Build examples
--------------

Build Debian source package.

    $ bitbake hello

Build non-Debianized source.
This is the simplest recipe to build non-Debianized source.

    $ bitbake localfiles

Build non-Debianized source.
This recipe fetches source code from remote, and has
build & run-time dependencies on Debian packages and non-Debian package `baz`.

    $ bitbake foo
