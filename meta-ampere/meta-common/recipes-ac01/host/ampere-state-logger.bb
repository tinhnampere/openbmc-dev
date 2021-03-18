LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5f4ed2144f2ed8db87f4f530d9f68710"
inherit systemd meson pkgconfig

DEPENDS = "boost sdbusplus libgpiod systemd phosphor-dbus-interfaces phosphor-logging"
RDEPENDS:${PN} += "libsystemd bash"

S = "${WORKDIR}/git/state-logger"

SRC_URI = "git://github.com/ampere-openbmc/ampere-misc;protocol=git;branch=ampere"
SRCREV = "4dc7d688419b6a1cf6268e240c798eec920477eb"

SYSTEMD_SERVICE:${PN} += "xyz.openbmc_project.state_logger.service"
