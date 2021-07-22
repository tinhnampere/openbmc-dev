POWER_SERVICE_PACKAGES = " \
                         phosphor-power \
                         phosphor-power-psu-monitor \
                         "

RDEPENDS_${PN}-extras_append_mtjade = " \
                                        ${POWER_SERVICE_PACKAGES} \
                                        webui-vue \
                                        phosphor-image-signing \
                                        phosphor-virtual-sensor \
                                        dbus-sensors \
                                        entity-manager \
                                      "

RDEPENDS_${PN}-inventory_append_mtjade = " \
                                        fault-monitor \
                                        id-button \
                                        tempevent-monitor \
                                        scp-failover \
                                        psu-hotswap-reset \
                                        "

RDEPENDS_${PN}-extras_remove_mtjade = " phosphor-hwmon"
VIRTUAL-RUNTIME_obmc-sensors-hwmon ?= "dbus-sensors"
