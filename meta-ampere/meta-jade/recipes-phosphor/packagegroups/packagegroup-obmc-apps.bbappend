RDEPENDS:${PN}-extras:append:mtjade = " \
                                       webui-vue \
                                       phosphor-image-signing \
                                       phosphor-virtual-sensor \
                                       phosphor-misc-usb-ctrl \
                                       scp-failover \
                                       fault-monitor \
                                       tempevent-monitor \
                                      "

RDEPENDS:${PN}-inventory:append:mtjade = " \
                                          dbus-sensors \
                                          entity-manager \
                                        "
RDEPENDS:${PN}-extras:remove:mtjade = " phosphor-hwmon"
VIRTUAL-RUNTIME_obmc-sensors-hwmon ?= "dbus-sensors"
RDEPENDS:${PN}-extras:append:mtjade = " phosphor-virtual-sensor"
