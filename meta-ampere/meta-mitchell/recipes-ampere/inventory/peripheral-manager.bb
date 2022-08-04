SUMMARY = "Peripheral Manager"
DESCRIPTION = "Daemon to monitor and report the platform peripheral status"
HOMEPAGE = "https://github.com/ampere-openbmc/ampere-misc"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1f1ec9217a57889c4e85d0d060512cdd"

inherit meson pkgconfig
inherit systemd

DEPENDS += "sdbusplus"
DEPENDS += "phosphor-dbus-interfaces"
DEPENDS += "sdeventplus"
DEPENDS += "phosphor-logging"
DEPENDS += "nlohmann-json"
DEPENDS += "i2c-tools"

S = "${WORKDIR}/git/peripheral-manager"
SRC_URI = "git://github.com/ampere-openbmc/ampere-misc.git;protocol=https;branch=ampere"
SRC_URI += " file://config.json"
SRCREV = "f206458b3c87ec4e8791d09b0048f7b4a4293526"

SYSTEMD_SERVICE:${PN} = "xyz.openbmc_project.peripheral.manager.service"

do_install:append() {
    install -d ${D}/etc/peripheral
    install -m 0644 -D ${WORKDIR}/config.json ${D}/etc/peripheral/config.json
}

