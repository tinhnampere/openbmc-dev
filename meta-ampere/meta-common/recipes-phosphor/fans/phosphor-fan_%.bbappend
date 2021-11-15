FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-Fix-condition-to-check-Fan-Present-value.patch \
            file://0002-support-action-to-set-speed-from-max-sensor-reading-.patch \
            file://0003-monitor-Support-target_path-option-in-configuration-.patch \
            file://0004-control-Support-target_path-option-in-configuration-.patch \
           "
