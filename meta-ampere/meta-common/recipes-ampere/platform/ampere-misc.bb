SUMMARY = "Ampere misc"
DESCRIPTION = "The Ampere's applications to handle platform behavior"
HOMEPAGE = "https://github.com/ampere-openbmc/ampere-misc"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=792dd876844979c80e1a4f859bc2a1e5"

FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

inherit meson pkgconfig
inherit systemd

DEPENDS += "sdbusplus"
DEPENDS += "phosphor-dbus-interfaces"
DEPENDS += "phosphor-logging"
DEPENDS += "systemd"
DEPENDS += "boost"
DEPENDS += "gpioplus"
DEPENDS += "sdeventplus"
DEPENDS += "libgpiod"
DEPENDS += "nlohmann-json"
DEPENDS += "i2c-tools"

RDEPENDS:${PN} += "bash"

SRC_URI = "git://github.com/ampere-openbmc/ampere-misc.git;protocol=https;branch=ampere"
SRCREV = "7197a9a70daa50c3afcf95ec1aca4917c257d7ac"

S = "${WORKDIR}/git"

PACKAGECONFIG = " state-logger ampere-cpld-fwupdate"
PACKAGECONFIG[nmi-manager] = "-Dnmi-manager=enabled, -Dnmi-manager=disabled"
PACKAGECONFIG[ampere-cpld-fwupdate] = "-Dampere-cpld-fwupdate=enabled, -Dampere-cpld-fwupdate=disabled"
PACKAGECONFIG[state-logger] = "-Dstate-logger=enabled, -Dstate-logger=disabled"
PACKAGECONFIG[mctp-ctrl] ??= "-Dmctp-ctrl=enabled -Dmctp-delay-before-add-terminus=2000 \
                              -Dmctp-delay-before-add-second-terminus=0 -Dmctp-checking-s1-ready-time-out=0,\
                              -Dmctp-ctrl=disabled"

SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "nmi-manager", "xyz.openbmc_project.nmi.manager.service nmi.service", "", d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "state-logger", "xyz.openbmc_project.state_logger.service", "", d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "mctp-ctrl", " xyz.openbmc_project.AmpereMctpCtrl.service", "", d)}"

