FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = " \
                         -Dwarm-reboot=disabled \
                       "

SRC_URI += " \
            file://ampere-obmc-power-start@.service \
           "

do_install:append() {
    cp ${WORKDIR}/ampere-obmc-power-start@.service ${D}${systemd_system_unitdir}/obmc-power-start@.service
}