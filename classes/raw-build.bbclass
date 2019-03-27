inherit common

# TODO: use ${SCH} as the command prefix of the specific bitbake function
SCH = "schroot -c ${CHROOT_NAME} -d ${WORKDIR} -- "

do_raw_build() {
	:
}
addtask raw_build after do_unpack before do_build

# TODO: consider providing do_raw_install() to merge binaries into rootfs
# and do_raw_deploy() to publish binaries as the final deliverable.
