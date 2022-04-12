FILESEXTRAPATHS:append := "${THISDIR}:"

SUMMARY = "Phosphor OpenBMC RAS monitor"
DESCRIPTION = "Phosphor OpenBMC PLDM RAS Handling Daemon"

PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

RDEPENDS:${PN} += "bash"

SRC_URI = " file://ampere_ras_monitor.sh \
            file://ampere_ras_sensors.sh \
          "

do_install () {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/ampere_ras_monitor.sh ${D}${sbindir}/
    install -m 0755 ${WORKDIR}/ampere_ras_sensors.sh ${D}${sbindir}/
}

