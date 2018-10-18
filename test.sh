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

#uncomment and modify to use not kazu git master for testing
#$E "cd poky/meta-eid; git remote add tr https://github.com/manut/meta-eid;"
#$E "cd poky/meta-eid; git fetch tr;"
#$E "cd poky/meta-eid; git reset --hard tr/master"

BITBAKE_TARGETS="hello localfiles foo"
for bb in $BITBAKE_TARGETS; do
	$E "source ./poky/meta-eid/setup.sh; USER=eid bitbake $bb"
done
