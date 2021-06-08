FILESEXTRAPATHS_append_mtjade := "${THISDIR}/${PN}:"

SRC_URI += "file://ssifbridge.service"

do_install_append_mtjade() {
    cp ${WORKDIR}/ssifbridge.service ${D}${systemd_system_unitdir}/ssifbridge.service
}
