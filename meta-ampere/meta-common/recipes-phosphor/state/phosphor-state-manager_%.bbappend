FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPS_CFG = "resetreason.conf"
DEPS_TGT = "phosphor-discover-system-state@.service"
SYSTEMD_OVERRIDE_${PN}-discover_append = "${DEPS_CFG}:${DEPS_TGT}.d/${DEPS_CFG}"

SRC_URI += " \
             file://ampere-reset-host-check@.service \
           "

AMPERE_RESET_HOST_CHECK_TMPL = "ampere-reset-host-check@.service"

do_install_append() {
    install -m 0644 ${WORKDIR}/${AMPERE_RESET_HOST_CHECK_TMPL} ${D}${systemd_unitdir}/system/phosphor-reset-host-check@.service
}

pkg_postinst_${PN}-obmc-targets_append() {
    rm "$D$systemd_system_unitdir/obmc-host-warm-reboot@0.target.requires/xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service"
    rm "$D$systemd_system_unitdir/obmc-host-warm-reboot@0.target.requires/obmc-host-force-warm-reboot@0.target"

    rm "$D$systemd_system_unitdir/obmc-host-reboot@0.target.requires/phosphor-reboot-host@0.service"
    rm "$D$systemd_system_unitdir/obmc-host-reboot@0.target.requires/obmc-host-shutdown@0.target"

    rm "$D$systemd_system_unitdir/obmc-host-force-warm-reboot@0.target.requires/obmc-host-stop@0.target"
    rm "$D$systemd_system_unitdir/obmc-host-force-warm-reboot@0.target.requires/phosphor-reboot-host@0.service"
}
