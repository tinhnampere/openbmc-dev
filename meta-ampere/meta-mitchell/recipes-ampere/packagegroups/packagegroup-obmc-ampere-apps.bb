SUMMARY = "OpenBMC for Ampere - Applications"
PR = "r1"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
        ${PN}-chassis \
        ${PN}-flash \
        ${PN}-system \
        "

PROVIDES += "virtual/obmc-chassis-mgmt"
PROVIDES += "virtual/obmc-flash-mgmt"
PROVIDES += "virtual/obmc-system-mgmt"

RPROVIDES:${PN}-chassis += "virtual-obmc-chassis-mgmt"
RPROVIDES:${PN}-flash += "virtual-obmc-flash-mgmt"
RPROVIDES:${PN}-system += "virtual-obmc-system-mgmt"

SUMMARY:${PN}-chassis = "Ampere Chassis"
RDEPENDS:${PN}-chassis = " \
                            obmc-phosphor-buttons-signals \
                            obmc-phosphor-buttons-handler \
                            ampere-hostctrl \
                            obmc-op-control-power \
                         "

SUMMARY:${PN}-flash = "Ampere Flash"
RDEPENDS:${PN}-flash = " \
                        phosphor-software-manager \
                       "

SUMMARY:${PN}-system = "Ampere System"
RDEPENDS:${PN}-system = " \
                         ampere-gpio-handling \
                         entity-manager \
                         dbus-sensors \
                         webui-vue \
                         phosphor-virtual-sensor \
                         ipmitool \
                         phosphor-sel-logger \
                         phosphor-logging \
                         libmctp \
                         mctp-ctrl \
                         pldm \
                        "

RDEPENDS:${PN}-extras:remove = " phosphor-hwmon"
VIRTUAL-RUNTIME_obmc-sensors-hwmon ?= "dbus-sensors"
RDEPENDS:${PN}-extras:append = " phosphor-virtual-sensor"
