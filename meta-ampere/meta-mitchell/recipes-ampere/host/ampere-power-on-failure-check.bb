SUMMARY = "Ampere Computing LLC Check Power On Sequence Implementation"
DESCRIPTION = "A host control implementation suitable for Ampere Computing LLC's systems"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit systemd
inherit obmc-phosphor-systemd

RDEPENDS:${PN} = "bash"
S = "${WORKDIR}"

SRC_URI = " \
           file://ampere-power-on-failure-check.service \
           file://ampere_power_on_failure_check.sh \
          "

SYSTEMD_PACKAGES = "${PN}"

HOST_ON_RESET_HOSTTMPL = "ampere-power-on-failure-check.service"
HOST_ON_RESET_HOSTINSTMPL = "ampere-power-on-failure-check.service"
HOST_ON_RESET_HOSTTGTFMT = "obmc-host-startmin@{0}.target"
HOST_ON_RESET_HOSTFMT = "../${HOST_ON_RESET_HOSTTMPL}:${HOST_ON_RESET_HOSTTGTFMT}.requires/${HOST_ON_RESET_HOSTINSTMPL}"
SYSTEMD_LINK:${PN} += "${@compose_list_zip(d, 'HOST_ON_RESET_HOSTFMT', 'OBMC_HOST_INSTANCES')}"
SYSTEMD_SERVICE:${PN} += "${HOST_ON_RESET_HOSTTMPL}"

do_install() {
    install -d ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/ampere_power_on_failure_check.sh ${D}/${sbindir}/
}
