FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://0001-ADCSensor-Add-PollRate-and-fix-PowerState-Always.patch \
            file://0002-ADCSensor-Use-device-name-to-match-the-ADC-sensors.patch \
            file://0003-ADCSensor-Add-support-DevName-option.patch \
           "
PACKAGECONFIG_mtjade = " \
                        adcsensor \
                        fansensor \
                        hwmontempsensor \
                        psusensor \
                        "