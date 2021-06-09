LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

inherit systemd meson pkgconfig

DEPENDS = "boost sdbusplus systemd phosphor-dbus-interfaces phosphor-logging nlohmann-json gpioplus"

RDEPENDS_${PN} += "libsystemd bash"

EXTRA_OEMESON_append = " \
    -Dboot-progress=enabled \
    -Derror-monitor=enabled \
    -Dpower-limit=enabled \
    -Dtemp-event-log=enabled \
    "

S = "${WORKDIR}/git"

SRC_URI = "git://github.com/ampere-openbmc/ampere-platform-mgmt.git;protocol=https;branch=ampere"
SRCREV = "2ccf690375596c2f8586ef5d00e2912aca16325c"
SRC_URI += " file://platform-config.json"


# Needed to install into the obmc-chassis-poweron target
TMPL_HOST_MNT = "xyz.openbmc_project.bootprogress.service"
INSTFMT_MNT = "xyz.openbmc_project.bootprogress.service"
POWERON_TGT = "obmc-chassis-poweron@{0}.target"
FMT_MNT = "../${TMPL_HOST_MNT}:${POWERON_TGT}.requires/${INSTFMT_MNT}"

SYSTEMD_SERVICE_${PN} += "${TMPL_HOST_MNT}"
SYSTEMD_SERVICE_${PN} += "xyz.openbmc_project.ampere_host_error_monitor.service"
SYSTEMD_SERVICE_${PN} += "xyz.openbmc_project.AmpSocPower.service"
SYSTEMD_LINK_${PN} += "${@compose_list(d, 'FMT_MNT', 'OBMC_CHASSIS_INSTANCES')}"

do_install_append_mtjade() {
    install -d ${D}${datadir}/${PN}
    install -m 0644 -D ${WORKDIR}/platform-config.json \
        ${D}${datadir}/${PN}/config.json
}
