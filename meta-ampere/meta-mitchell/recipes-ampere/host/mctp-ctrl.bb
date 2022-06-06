SUMMARY = "Ampere MCTP Control"
DESCRIPTION = "Daemon to handle MCTP D-Bus interface base on the power state and host state"
HOMEPAGE = "https://github.com/ampere-openbmc/ampere-misc"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99486d9fac05d4a39881f69367065529"

RDEPENDS:${PN} = "bash"

inherit meson pkgconfig
inherit systemd

DEPENDS += "systemd"
DEPENDS += "boost"
DEPENDS += "sdbusplus"
DEPENDS += "phosphor-dbus-interfaces"
DEPENDS += "gpioplus"

S = "${WORKDIR}/git/mctp-ctrl"

SRC_URI = "git://github.com/ampere-openbmc/ampere-misc;protocol=https;branch=ampere"
SRCREV = "1c1b25be4fdf4cc6dc8d5811fd57d42866d9378b"

SRC_URI += " \
    file://xyz.openbmc_project.AmpereMctpCtrl.service \
    file://ampere-slave-present.sh \
    "

SYSTEMD_SERVICE:${PN} += "xyz.openbmc_project.AmpereMctpCtrl.service"

EXTRA_OEMESON = " \
        -Ddelay-before-add-terminus=1000 \
        "

do_install () {
    install -d ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/build/ampere-mctp-ctrl ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/ampere-slave-present.sh ${D}/${sbindir}/
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/xyz.openbmc_project.AmpereMctpCtrl.service ${D}${systemd_unitdir}/system
}
