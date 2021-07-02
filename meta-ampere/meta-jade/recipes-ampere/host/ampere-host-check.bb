SUMMARY = "Ampere Computing LLC Host Check"
DESCRIPTION = "A host check service suitable for Ampere Computing LLC's systems"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit systemd
inherit obmc-phosphor-systemd

DEPENDS += "systemd"
RDEPENDS_${PN} += "libsystemd"
RDEPENDS_${PN} += "bash"

S = "${WORKDIR}"

SRC_URI = " \
            file://ampere_host_check.sh \
          "

HOST_ON_RESET_HOSTTMPL = "ampere-host-on-host-check@.service"
HOST_ON_RESET_HOSTINSTMPL = "ampere-host-on-host-check@{0}.service"
HOST_ON_RESET_HOSTTGTFMT = "obmc-host-startmin@{0}.target"
HOST_ON_RESET_HOSTFMT = "../${HOST_ON_RESET_HOSTTMPL}:${HOST_ON_RESET_HOSTTGTFMT}.requires/${HOST_ON_RESET_HOSTINSTMPL}"
SYSTEMD_LINK_${PN} += "${@compose_list_zip(d, 'HOST_ON_RESET_HOSTFMT', 'OBMC_HOST_INSTANCES')}"

SYSTEMD_SERVICE_${PN} += "${HOST_ON_RESET_HOSTTMPL}"

# Run when power off/power on the host
do_install() {
    install -d ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/ampere_host_check.sh ${D}/${sbindir}/ampere_host_check.sh
}

