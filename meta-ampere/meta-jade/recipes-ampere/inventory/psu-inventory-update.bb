SUMMARY = "Update PSU inventory"
DESCRIPTION = "Setup PSU inventory read from PSU FRU EEPROM"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch systemd

RDEPENDS_${PN} = "${VIRTUAL-RUNTIME_base-utils}"
RDEPENDS_${PN} += "bash"

SYSTEMD_SERVICE_${PN} = "psu-inventory-update@.service"
SYSTEMD_SERVICE_${PN} += "psu-inventory-update@0.service"
SYSTEMD_SERVICE_${PN} += "psu-inventory-update@1.service"

SRC_URI = "file://${BPN}.sh file://${BPN}@.service"

S = "${WORKDIR}"
do_install() {
    install -d ${D}${bindir} ${D}${systemd_system_unitdir}
    install ${BPN}.sh ${D}${bindir}/
    install -m 644 ${BPN}@.service ${D}${systemd_system_unitdir}/
}
