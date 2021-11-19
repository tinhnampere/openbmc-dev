FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

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
