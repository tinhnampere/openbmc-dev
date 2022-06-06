SUMMARY = "Ampere Computing LLC Fault Monitor"
DESCRIPTION = "Monitor fault events and update fault led status for Ampere systems"
PR = "r1"

LICENSE = "Apache-2.0"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit systemd
inherit obmc-phosphor-systemd

RDEPENDS:${PN} = "bash"

FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://ampere_fault_monitor.sh \
           "

SYSTEMD_SERVICE:${PN} = "ampere_fault_monitor.service"

do_install() {
    install -d ${D}/${sbindir}
    install -m 755 ${WORKDIR}/ampere_fault_monitor.sh ${D}/${sbindir}/
}
