# https://hub.docker.com/r/manut/eid-base/
FROM eidproject/eid-base
RUN rm -rf /home/eid/poky/meta-eid
