FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
FILESEXTRAPATHS:append := "${THISDIR}/${PN}/peripheral-manager:"

PACKAGECONFIG = " peripheral-manager state-logger ampere-cpld-fwupdate"

SRC_URI += " \
             file://peripheral_config.json \
           "

do_install:append () {
    install -d ${D}/etc/peripheral
    install -m 0644 -D ${WORKDIR}/peripheral_config.json ${D}/etc/peripheral/config.json
}
