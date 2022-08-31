FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " prevent-host-control"
# The disable host control when the fan sensors are not created.
PACKAGECONFIG[prevent-host-control] = "-Dprevent-host-control=enabled"

SRC_URI += " \
            file://0001-set-fan-presence-condition-500-rpm.patch \
            file://0002-control-Support-target_path-option-in-configuration-.patch \
            file://0003-monitor-Support-target_path-option-in-configuration-.patch \
            file://0004-control-support-sensor_path-option.patch \
            file://0005-add-disabled-host-control-option.patch \
            file://0006-Add-json-action-to-set-target-from-group-max.patch \
           "
