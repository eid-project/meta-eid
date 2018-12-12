#!/bin/bash

set -xe

IMAGENAME=eid-image
CNAME=eid

E="docker exec -it -u1000 $CNAME /bin/bash -c "

docker run \
	--workdir /home/eid \
	--cap-add SYS_ADMIN \
	-u1000 \
	--rm \
	-i \
	-d \
	--name $CNAME \
	$IMAGENAME

# rebuild chroot
$E "sudo rm -rf /etc/schroot/chroot.d/buster-amd64-eid* /home/eid/build/buster-amd64-eid"
$E "source ./poky/meta-eid/setup.sh; sudo ../poky/meta-eid/scripts/setup-sbuild.sh"

# delete existing configuration
$E "sudo rm -rf /home/eid/build/conf"

BITBAKE_TARGETS="hello localfiles foo"
for bb in $BITBAKE_TARGETS; do
	$E "source ./poky/meta-eid/setup.sh; USER=eid bitbake $bb"
done
