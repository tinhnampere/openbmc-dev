FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

TMPL_POWERSUPPLY = "phosphor-gpio-presence@.service"
INSTFMT_POWERSUPPLY = "phosphor-gpio-presence@{0}.service"
POWERSUPPLY_TGT = "multi-user.target"
FMT_POWERSUPPLY = "../${TMPL_POWERSUPPLY}:${POWERSUPPLY_TGT}.requires/${INSTFMT_POWERSUPPLY}"

SYSTEMD_LINK:${PN}-presence:append:mtjade = " ${@compose_list(d, 'FMT_POWERSUPPLY', 'OBMC_POWER_SUPPLY_INSTANCES')}"

POWERSUPPLY_ENV_FMT  = "obmc/gpio/phosphor-power-supply-{0}.conf"

SYSTEMD_ENVIRONMENT_FILE:${PN}-presence:append:mtjade = " ${@compose_list(d, 'POWERSUPPLY_ENV_FMT', 'OBMC_POWER_SUPPLY_INSTANCES')}"

RDEPENDS:${PN}-monitor += "bash"

SRC_URI += " \
            file://phosphor-multi-gpio-monitor.json \
            file://ampere_psu_reset_hotswap.sh \
            file://toggle_identify_led.sh \
            "

SYSTEMD_SERVICE:${PN}-monitor += "ampere-host-shutdown-ack@.service"
SYSTEMD_SERVICE:${PN}-monitor += "id-button-pressed.service"
SYSTEMD_SERVICE:${PN}-monitor += "psu1_hotswap_reset.service"
SYSTEMD_SERVICE:${PN}-monitor += "psu2_hotswap_reset.service"

FILES:${PN}-monitor += "/usr/share/${PN}/phosphor-multi-gpio-monitor.json"
FILES:${PN}-monitor += "/usr/bin/ampere_psu_reset_hotswap.sh"
FILES:${PN}-monitor += "/usr/bin/toggle_identify_led.sh"

SYSTEMD_LINK:${PN}-monitor:append:mtjade += " ../phosphor-multi-gpio-monitor.service:multi-user.target.requires/phosphor-multi-gpio-monitor.service"

do_install:append:mtjade() {
    install -d ${D}${bindir}
    install -m 0644 ${WORKDIR}/phosphor-multi-gpio-monitor.json ${D}${datadir}/${PN}/
    install -m 0755 ${WORKDIR}/ampere_psu_reset_hotswap.sh ${D}${bindir}/
    install -m 0755 ${WORKDIR}/toggle_identify_led.sh ${D}${bindir}/
}
