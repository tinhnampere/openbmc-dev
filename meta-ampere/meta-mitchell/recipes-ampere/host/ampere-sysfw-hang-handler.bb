SUMMARY = "Ampere Computing LLC System Firmware Hang Handler"
DESCRIPTION = "A host control implementation suitable for Ampere Computing LLC's systems"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit systemd
inherit obmc-phosphor-systemd

RDEPENDS:${PN} = "bash"
FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI = " \
           file://ampere-sysfw-hang-handler.service \
           file://ampere_sysfw_hang_handler.sh \
          "

SYSTEMD_SERVICE:${PN} = "ampere-sysfw-hang-handler.service"

do_install() {
    install -d ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/ampere_sysfw_hang_handler.sh ${D}/${sbindir}/
}
