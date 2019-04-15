inherit common

# TODO: use ${SCH} as the command prefix of the specific bitbake function
SCH = "schroot -c ${CHROOT_NAME} -d ${WORKDIR} -- "
SCH_ROOT = "schroot -c ${CHROOT_NAME} -d ${WORKDIR} -u root -- "

do_install_builddep() {
	${SCH_ROOT} apt install -y ${DEB_DEPENDS}
}
addtask install_builddep after do_unpack before do_raw_build

do_raw_build() {
	:
}
addtask raw_build after do_unpack before do_uninstall_builddep

do_uninstall_builddep() {
	${SCH_ROOT} apt purge -y ${DEB_DEPENDS}
	${SCH_ROOT} apt autoremove -y
}
addtask uninstall_builddep after do_raw_build before do_build

# TODO: consider providing do_raw_install() to merge binaries into rootfs
# and do_raw_deploy() to publish binaries as the final deliverable.
