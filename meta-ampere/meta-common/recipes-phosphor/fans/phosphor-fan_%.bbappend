FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-set-fan-presence-condition-500-rpm.patch \
            file://0002-support-action-to-set-speed-from-max-sensor-reading-.patch \
            file://0003-control-Support-target_path-option-in-configuration-.patch \
            file://0004-monitor-Support-target_path-option-in-configuration-.patch \
            file://0005-meta-ampere-phosphor-fan-support-sensor_path-option.patch \
           "
