FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://0001-ADCSensor-Add-PollRate-and-fix-PowerState-Always.patch \
            file://0002-ADCSensor-Use-device-name-to-match-the-ADC-sensors.patch \
            file://0003-ADCSensor-Add-support-DevName-option.patch \
            file://0004-Dbus-sensors-restructure-the-code-handle-PowerState-.patch \
            file://0005-ADCSensor-FanSensor-Support-ChassisState-attribute.patch \
           "
PACKAGECONFIG_mtjade = " \
                        adcsensor \
                        fansensor \
                        hwmontempsensor \
                        psusensor \
                        "