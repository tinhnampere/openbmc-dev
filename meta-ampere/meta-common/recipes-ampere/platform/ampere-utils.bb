SUMMARY = "Ampere Platform Environment Definitions"
DESCRIPTION = "Ampere Platform Environment Definitions"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit systemd
inherit obmc-phosphor-systemd

RDEPENDS:${PN} = "bash"
DEPENDS = "zlib"

SRC_URI = "git://github.com/ampere-openbmc/ampere-platform-mgmt.git;protocol=https;branch=ampere"

SRC_URI:append = " \
           file://ampere_add_redfishevent.sh \
           file://ampere_update_mac.sh \
           file://ampere_post_fan_status_monitor.sh \
           file://ampere_fan_status_monitor.sh \
           file://ampere_fan_status_monitor.service \
          "
SRCREV = "26ec37cd8275e881c538677b4ebd0519e112b4bc"

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = " \
                         ampere_fan_status_monitor.service \
                        "

S = "${WORKDIR}/git/utilities/flash"
ROOT = "${STAGING_DIR_TARGET}"

LDFLAGS += "-L ${ROOT}/usr/lib/ -lz "

do_compile() {
    ${CC} ${S}/ampere_eeprom_prog.c -o ${S}/ampere_eeprom_prog -I${ROOT}/usr/include/ ${LDFLAGS}
    ${CC} ${S}/nvparm.c -o ${S}/nvparm -I${ROOT}/usr/include/ ${LDFLAGS}
    ${CC} ${S}/ampere_fru_upgrade.c -o ${S}/ampere_fru_upgrade -I${ROOT}/usr/include/ ${LDFLAGS}
}

CHECK_FAN_STATUS_TGT = "ampere_fan_status_monitor.service"
CHECK_FAN_STATUS_INSTMPL = "ampere_fan_status_monitor.service"
AMPERE_HOST_RUNNING = "obmc-host-already-on@{0}.target"
CHECK_FAN_STATUS_FMT = "../${CHECK_FAN_STATUS_TGT}:${AMPERE_HOST_RUNNING}.wants/${CHECK_FAN_STATUS_INSTMPL}"
SYSTEMD_LINK:${PN} += "${@compose_list_zip(d, 'CHECK_FAN_STATUS_FMT', 'OBMC_HOST_INSTANCES')}"
SYSTEMD_SERVICE:${PN} += "${CHECK_FAN_STATUS_TGT}"

do_install() {
    install -d ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/ampere_add_redfishevent.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/ampere_update_mac.sh ${D}/${sbindir}/
    install -m 0755 ${S}/ampere_eeprom_prog ${D}/${sbindir}/ampere_eeprom_prog
    install -m 0755 ${S}/ampere_fru_upgrade ${D}/${sbindir}/ampere_fru_upgrade
    install -m 755 ${WORKDIR}/ampere_post_fan_status_monitor.sh ${D}/${sbindir}/
    install -m 755 ${WORKDIR}/ampere_fan_status_monitor.sh ${D}/${sbindir}/
}
