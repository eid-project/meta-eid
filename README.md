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
is recommended.

Docker
------

Ensure that docker is installed on your machine.

If http\_proxy, etc. is set as environment on your terminal it is
redirected into the docker container.

To build, start and change into the container:

    $ make

To setup meta-eid inside the container:

    $ source ./poky/meta-eid/setup.sh

Continue with 'Examples'

Remember, containers are stateless.
If you leave the container all changes inside the container are lost.
To avoid this, use the following command on a second terminal:

    $ docker commit eid eid-image:mysnapshot

To start this snapshot:

    $ IMAGENAME=eid-image:mysnapshot make

Native
------

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


Examples
--------

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
