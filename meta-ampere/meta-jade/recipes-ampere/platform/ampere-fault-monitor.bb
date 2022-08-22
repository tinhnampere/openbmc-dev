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
            file://ampere_check_fault_gpio.sh \
            file://ampere_post_check_fault_gpio.sh \
           "

SYSTEMD_SERVICE:${PN} = " \
                         ampere_fault_monitor.service \
                        "

FAULT_GPIO_START_S0_TGT = "ampere_check_fault_gpio_start_S0_host@.service"
FAULT_GPIO_START_S0_INSTMPL = "ampere_check_fault_gpio_start_S0_host@{0}.service"
HOST_WARM_REBOOT_FORCE_TGTFMT = "obmc-host-force-warm-reboot@{0}.target"
FAULT_GPIO_START_S0_FORCE_WARM_REBOOT_FMT = "../${FAULT_GPIO_START_S0_TGT}:${HOST_WARM_REBOOT_FORCE_TGTFMT}.requires/${FAULT_GPIO_START_S0_INSTMPL}"
SYSTEMD_LINK:${PN} += "${@compose_list_zip(d, 'FAULT_GPIO_START_S0_FORCE_WARM_REBOOT_FMT', 'OBMC_HOST_INSTANCES')}"
SYSTEMD_SERVICE:${PN} += "${FAULT_GPIO_START_S0_TGT}"

FAULT_GPIO_START_S1_TGT = "ampere_check_fault_gpio_start_S1_host@.service"
FAULT_GPIO_START_S1_INSTMPL = "ampere_check_fault_gpio_start_S1_host@{0}.service"
FAULT_GPIO_START_S1_FORCE_WARM_REBOOT_FMT = "../${FAULT_GPIO_START_S1_TGT}:${HOST_WARM_REBOOT_FORCE_TGTFMT}.requires/${FAULT_GPIO_START_S1_INSTMPL}"
SYSTEMD_LINK:${PN} += "${@compose_list_zip(d, 'FAULT_GPIO_START_S1_FORCE_WARM_REBOOT_FMT', 'OBMC_HOST_INSTANCES')}"
SYSTEMD_SERVICE:${PN} += "${FAULT_GPIO_START_S1_TGT}"

HOST_ON_STARTMIN_TGTFMT = "obmc-host-startmin@{0}.target"
FAULT_GPIO_START_S0_STARTMIN_FMT = "../${FAULT_GPIO_START_S0_TGT}:${HOST_ON_STARTMIN_TGTFMT}.requires/${FAULT_GPIO_START_S0_INSTMPL}"
SYSTEMD_LINK:${PN} += "${@compose_list_zip(d, 'FAULT_GPIO_START_S0_STARTMIN_FMT', 'OBMC_HOST_INSTANCES')}"

FAULT_GPIO_START_S1_STARTMIN_FMT = "../${FAULT_GPIO_START_S1_TGT}:${HOST_ON_STARTMIN_TGTFMT}.requires/${FAULT_GPIO_START_S1_INSTMPL}"
SYSTEMD_LINK:${PN} += "${@compose_list_zip(d, 'FAULT_GPIO_START_S1_STARTMIN_FMT', 'OBMC_HOST_INSTANCES')}"

FAULT_GPIO_STOP_TGT = "ampere_check_fault_gpio_stop_host@.service"
FAULT_GPIO_STOP_INSTMPL = "ampere_check_fault_gpio_stop_host@{0}.service"
FAULT_GPIO_STOP_FMT = "../${FAULT_GPIO_STOP_TGT}:${HOST_ON_STARTMIN_TGTFMT}.wants/${FAULT_GPIO_STOP_INSTMPL}"
SYSTEMD_LINK:${PN} += "${@compose_list_zip(d, 'FAULT_GPIO_STOP_FMT', 'OBMC_HOST_INSTANCES')}"
SYSTEMD_SERVICE:${PN} += "${FAULT_GPIO_STOP_TGT}"

do_install() {
    install -d ${D}/${sbindir}
    install -m 755 ${WORKDIR}/ampere_fault_monitor.sh ${D}/${sbindir}/
    install -m 755 ${WORKDIR}/ampere_check_fault_gpio.sh ${D}/${sbindir}/
    install -m 755 ${WORKDIR}/ampere_post_check_fault_gpio.sh ${D}/${sbindir}/
}
