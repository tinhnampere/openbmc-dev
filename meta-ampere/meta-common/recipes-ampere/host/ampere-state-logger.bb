LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5f4ed2144f2ed8db87f4f530d9f68710"
inherit systemd meson pkgconfig

DEPENDS = "boost sdbusplus libgpiod systemd phosphor-dbus-interfaces phosphor-logging"
RDEPENDS:${PN} += "libsystemd bash"

S = "${WORKDIR}/git/state-logger"

SRC_URI = "git://github.com/ampere-openbmc/ampere-misc.git;protocol=https;branch=ampere"
SRCREV = "677c1db1347a6c3967106d0322076509e6a1dca0"

SYSTEMD_SERVICE:${PN} += "xyz.openbmc_project.state_logger.service"
