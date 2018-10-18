FROM debian:buster

USER root

RUN export DEBIAN_FRONTEND noninteractive ;\
    apt-get update -y ;\
    apt-get install -y --no-install-recommends \
        sudo \
        git

RUN useradd -d /home/eid -U -m -s /bin/bash eid
RUN echo  "eid:eid" | chpasswd
RUN echo "root:eid" | chpasswd

RUN echo "%eid  ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/eidgrp
RUN chmod 0440 /etc/sudoers.d/eidgrp

RUN apt-get install -y ca-certificates

RUN cd /home/eid ;\
    su -c "git clone https://git.yoctoproject.org/git/poky.git" eid

RUN cd /home/eid/poky ;\
    su -c "git clone https://github.com/zuka0828/meta-eid.git" eid

RUN cd /home/eid ;\
    echo y | ./poky/meta-eid/scripts/install-deps.sh

RUN sbuild-adduser eid

# poky runtime dependencies
RUN export DEBIAN_FRONTEND noninteractive ;\
    apt-get update -y ;\
    apt-get install -y --no-install-recommends \
       python2 gawk wget git-core diffstat unzip texinfo gcc-multilib \
       build-essential chrpath socat cpio python python3 python3-pip \
       python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm

RUN export DEBIAN_FRONTEND noninteractive ;\
    apt-get install -y --no-install-recommends \
       locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

RUN cd /home/eid ;\
    su -c "source ./poky/meta-eid/setup.sh" eid

RUN cd /home/eid/build ;\
    ../poky/meta-eid/scripts/setup-sbuild.sh

USER eid

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "/bin/bash" ]
