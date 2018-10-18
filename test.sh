#!/bin/bash

set -xe

IMAGENAME=eid-image
CNAME=eid

E="docker exec -it -u1000 -w /home/eid $CNAME /bin/bash -c "
G="docker exec -it -u1000 -w /home/eid/poky/meta-eid $CNAME /bin/bash -c "

docker run \
	-w /home/eid \
	--cap-add SYS_ADMIN \
	-u1000 \
	--rm \
	-i \
	-d \
	--name $CNAME \
	$IMAGENAME

#uncomment and modify to use not kazu git master for testing
#$G "git remote add tr https://github.com/manut/meta-eid;"
#$G "git fetch tr;"
#$G "git reset --hard tr/master"

BITBAKE_TARGETS="hello localfiles foo"
for bb in $BITBAKE_TARGETS; do
	$E "source ./poky/meta-eid/setup.sh; bitbake $bb"
done
