RDEPENDS:${PN}-extras:append:mtjade = " \
                                       webui-vue \
                                       phosphor-image-signing \
                                       phosphor-virtual-sensor \
                                       scp-failover \
                                       tempevent-monitor \
                                      "

RDEPENDS:${PN}-inventory:append:mtjade = " \
                                          fault-monitor \
                                          id-button \
                                          psu-hotswap-reset \
                                          host-gpio-handling \
                                          dbus-sensors \
                                          entity-manager \
                                        "
RDEPENDS:${PN}-extras:remove:mtjade = " phosphor-hwmon"
VIRTUAL-RUNTIME_obmc-sensors-hwmon ?= "dbus-sensors"
RDEPENDS:${PN}-extras:append:mtjade = " phosphor-virtual-sensor"
