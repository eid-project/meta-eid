[![Build Status](https://travis-ci.org/eid-project/meta-eid.svg?branch=master)](https://travis-ci.org/eid-project/meta-eid)

meta-eid
========

meta-eid provides the minimal configurations, classes, and recipes
for bitbake to build Debian packages or other extra sources.

This layer is just a working repository for finding better build
infrastructure to build Debian packages with bitbake.

Community Resources
===================

Project home
------------

* https://github.com/eid-project/meta-eid
* Used to host code and track issues

Testing
-------

* https://travis-ci.org/eid-project/meta-eid

Mailing list
------------

* meta-eid@googlegroups.com
* Used for patch review and technical discussions

System Requirements
===================

meta-eid is now developed and tested on the following environment.

* Build environment: Debian GNU/Linux 10 buster
* Poky version: Yocto Project 2.6 thud
* Architecture: amd64

How to use
==========

meta-eid can be used in a docker container.
This is the easiest way to ensure running in a validated environment.
Please see [Docker](#Docker) section.

Another option is to run meta-eid directly on a Linux machine.
Debian 10 is recommended. It is called [native method](#native).

Docker
------

Ensure that docker is installed on your machine.

If http\_proxy, etc. is set as environment on your terminal it is
redirected into the docker container.

To build, start and change into the container:

    $ git clone https://github.com/eid-project/meta-eid.git
    $ cd meta-eid
    $ make
    (docker) $ source ./poky/meta-eid/setup.sh
    (docker) $ sudo -E ../poky/meta-eid/scripts/setup-sbuild.sh

Now you can continue with [Build examples](#build-examples).

Commit changes made inside the container
----------------------------------------

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

Run setup scripts.

    $ source ./poky/meta-eid/setup.sh
    $ sudo -E ../poky/meta-eid/scripts/setup-sbuild.sh

(Optional) Add proxy setting into the schroot if you need.
Please replace `http://your.proxy.server:1234` below to your proxy server.

    $ sudo sh -c "echo 'acquire::http::proxy \"http://your.proxy.server:1234\";' \
      > chroot/${DEBIAN_CODENAME}-${DEBIAN_ARCH}-eid/etc/apt/apt.conf.d/proxy"

Now you can continue with [Build examples](#build-examples).

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
