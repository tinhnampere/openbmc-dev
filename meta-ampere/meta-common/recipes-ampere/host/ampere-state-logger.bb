LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1f1ec9217a57889c4e85d0d060512cdd"
inherit systemd meson pkgconfig

DEPENDS = "boost sdbusplus libgpiod systemd phosphor-dbus-interfaces phosphor-logging"
RDEPENDS:${PN} += "libsystemd bash"

S = "${WORKDIR}/git/state-logger"

SRC_URI = "git://github.com/ampere-openbmc/ampere-misc.git;protocol=https;branch=ampere"
SRCREV = "1c1b25be4fdf4cc6dc8d5811fd57d42866d9378b"

SYSTEMD_SERVICE:${PN} += "xyz.openbmc_project.state_logger.service"
