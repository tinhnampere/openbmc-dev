FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPS_CFG = "resetreason.conf"
DEPS_TGT = "phosphor-discover-system-state@.service"
SYSTEMD_OVERRIDE:${PN}-discover:append = "${DEPS_CFG}:${DEPS_TGT}.d/${DEPS_CFG}"

FILES:${PN} += "${systemd_system_unitdir}/*"
DEPENDS += "gpioplus libgpiod"

SRC_URI += " \
             file://0001-Limit-power-actions-when-the-host-is-off.patch \
             file://0002-Support-checking-host-status-via-GPIO-pins.patch \
             file://0003-remove-throwing-exception-when-calling-Dbus-method-i.patch \
           "
