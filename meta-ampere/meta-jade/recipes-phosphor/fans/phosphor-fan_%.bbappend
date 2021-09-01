FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Fix-condition-to-check-Fan-Present-value.patch \
            file://0002-support-action-to-set-speed-from-max-sensor-reading-.patch \
            file://0003-monitor-Support-target_path-option-in-configuration-.patch \
            file://0004-control-Support-target_path-option-in-configuration-.patch \
            file://phosphor-fan-control-init@.service \
            file://phosphor-fan-monitor-init@.service \
           "

do_install:append() {
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/phosphor-fan-monitor-init@.service ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/phosphor-fan-control-init@.service ${D}${systemd_system_unitdir}
}
