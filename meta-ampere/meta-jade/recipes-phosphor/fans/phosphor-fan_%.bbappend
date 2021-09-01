FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

RDEPENDS:${PN} += "bash"

SRC_URI += " \
            file://phosphor-fan-control-init@.service \
            file://phosphor-fan-monitor-init@.service \
            file://ampere_set_fan_max_speed.sh \
           "
SYSTEMD_OVERRIDE:phosphor-fan-control += "fan-set-max-speed.conf:phosphor-fan-control@0.service.d/fan-set-max-speed.conf"
SYSTEMD_OVERRIDE:phosphor-fan-monitor += "fan-set-max-speed.conf:phosphor-fan-monitor@0.service.d/fan-set-max-speed.conf"

FILES:${PN}-control += " ${bindir}/ampere_set_fan_max_speed.sh"

do_install:append() {
  install -d ${D}${bindir}
  install -m 0755 ${WORKDIR}/ampere_set_fan_max_speed.sh ${D}${bindir}/ampere_set_fan_max_speed.sh
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/phosphor-fan-monitor-init@.service ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/phosphor-fan-control-init@.service ${D}${systemd_system_unitdir}
}
