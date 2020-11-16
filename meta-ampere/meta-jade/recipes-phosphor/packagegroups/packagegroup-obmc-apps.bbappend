POWER_SERVICE_PACKAGES = " \
                         phosphor-power \
                         phosphor-power-psu-monitor \
                         "

RDEPENDS_${PN}-extras_append_mtjade = " \
                                        ${POWER_SERVICE_PACKAGES} \
                                        phosphor-webui \
                                        phosphor-image-signing \
                                        phosphor-virtual-sensor \
                                      "
RDEPENDS_${PN}-inventory_append_mtjade = " fault-monitor id-button tempevent-monitor psu-hotswap-reset"
