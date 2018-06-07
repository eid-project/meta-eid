Common variables
================

* `USER`: Normal user name
* `HOME`: Home directory of `USER`
* `URI_PROXY`: URI of proxy server (optional)

Standard Usage
==============

Install sbuild

NOTE: debhelper is required to build source package with `sbuild` command

    $ sudo apt-get install sbuild debhelper

Add myself into sbuild user

    $ sudo sbuild-adduser ${USER}

(Optional) Copy sbuild configuration template

    $ cp /usr/share/doc/sbuild/examples/example.sbuildrc ${HOME}.sbuildrc

Log in again, then create chroot

    $ sudo sbuild-createchroot buster /srv/chroot/buster-amd64-sbuild http://ftp.jp.debian.org/debian
    $ schroot -l
    chroot:buster-amd64-sbuild

(Optional) Add proxy setting into the chroot

    $ sudo sbuild-shell buster-amd64-sbuild
    (chroot) # echo 'acquire::http::proxy "${URI_PROXY}";' >>  /etc/apt/apt.conf.d/proxy
    (chroot) # exit

Update sbuild environment

(u: update, d: dist-upgrade, c: clean, a: autoclean, r: autoremove)

    $ sbuild-update -udcar buster

Build hello (in extracted source tree)

    $ apt-get source hello
    $ cd hello-*
    $ sbuild -d buster

Build openssl (specifying version)

    $ sbuild -d buster openssl_1.1.0h-4

Build bc (specifying .dsc)

    $ apt-get source -d bc
    $ sbuild -d buster bc_*.dsc

Delete chroot (manually)

    $ sudo rm -r /srv/chroot/buster-amd64-sbuild
    $ sudo rm /etc/schroot/chroot.d/buster-amd64-sbuild-*
    $ sudo rm /etc/sbuild/chroot/buster-amd64-sbuild

`sbuild-destroychroot` doesn't work because it tries to remove
not `/etc/schroot/chroot.d/buster-amd64-sbuild-*`
but `/etc/schroot/chroot.d/buster-amd64-sbuild` then failed.
