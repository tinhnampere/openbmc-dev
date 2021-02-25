SUMMARY = "Card Manager"
DESCRIPTION = "Daemon to monitor and report the status of NIC"
HOMEPAGE = "https://github.com/openbmc/phosphor-nvme"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

inherit meson pkgconfig
inherit systemd

DEPENDS += "sdbusplus"
DEPENDS += "phosphor-dbus-interfaces"
DEPENDS += "sdeventplus"
DEPENDS += "phosphor-logging"
DEPENDS += "nlohmann-json"
DEPENDS += "i2c-tools"

SRC_URI += " \
            file://LICENSE \
            file://card_manager.cpp \
            file://card_manager.hpp \
            file://cards.cpp \
            file://cards.hpp \
            file://i2c.h \
            file://sdbusplus.hpp \
            file://smbus.cpp \
            file://smbus.hpp \
            file://main.cpp \
            file://config.json \
            file://meson.build \
            file://xyz.openbmc_project.card.manager.service.in \
           "

S = "${WORKDIR}"

SYSTEMD_SERVICE_${PN} = "xyz.openbmc_project.card.manager.service"
