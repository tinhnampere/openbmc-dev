FILESEXTRAPATHS:prepend:mtjade := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://0001-adcsensor-Match-the-sensor-device-name.patch \
            file://0002-adcsensor-Add-support-DevName-option.patch \
           "
PACKAGECONFIG:mtjade = " \
                        adcsensor \
                        fansensor \
                        hwmontempsensor \
                        psusensor \
                        "