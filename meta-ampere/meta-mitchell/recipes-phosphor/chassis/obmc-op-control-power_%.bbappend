FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://ampere-op-power-start@.service \
           "

do_install:append() {
    cp ${WORKDIR}/ampere-op-power-start@.service ${D}${systemd_system_unitdir}/op-power-start@.service
}
