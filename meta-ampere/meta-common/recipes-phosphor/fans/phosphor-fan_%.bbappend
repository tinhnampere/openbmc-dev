FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " prevent-host-control"
# The disable host control when the fan sensors are not created.
PACKAGECONFIG[prevent-host-control] = "--enable-prevent-host-control, --disable-prevent-host-control"

SRC_URI += " \
            file://0001-set-fan-presence-condition-500-rpm.patch \
            file://0002-support-action-to-set-speed-from-max-sensor-reading-.patch \
            file://0003-control-Support-target_path-option-in-configuration-.patch \
            file://0004-monitor-Support-target_path-option-in-configuration-.patch \
            file://0005-meta-ampere-phosphor-fan-support-sensor_path-option.patch \
            file://0006-implement-disabled-host-control-option.patch \
           "
