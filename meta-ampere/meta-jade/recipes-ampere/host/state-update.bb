SUMMARY = "Host State Updater"
DESCRIPTION = "Daemon to verify and update the CurrentHostState Dbus property"
HOMEPAGE = "https://github.com/ampere-openbmc/ampere-misc"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7dc32e347ce199c5b3f5f131704e7251"

inherit meson pkgconfig
inherit systemd

DEPENDS += "boost"
DEPENDS += "sdbusplus"
DEPENDS += "systemd"
DEPENDS += "phosphor-dbus-interfaces"
DEPENDS += "phosphor-logging"
DEPENDS += "nlohmann-json"
DEPENDS += "gpioplus"

S = "${WORKDIR}/git/state-update"

SRC_URI = "git://git@gitlab.com/AmpereComputing/bmc/openbmc/ampere-misc.git;protocol=ssh;branch=main"
SRC_URI += " file://state-update-config.json"
SRCREV = "004b2572571644e94e1f2788a1a1507f38efe350"

SYSTEMD_SERVICE_${PN} += "xyz.openbmc_project.AmpHostState.service"

do_install_append_mtjade() {
    install -d ${D}${datadir}/${PN}
    install -m 0644 -D ${WORKDIR}/state-update-config.json \
        ${D}${datadir}/${PN}/config.json
}
