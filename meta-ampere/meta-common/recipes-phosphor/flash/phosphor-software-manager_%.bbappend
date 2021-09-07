FILESEXTRAPATHS_prepend_mtjade := "${THISDIR}/${PN}:"

PACKAGECONFIG[flash_bios] = "-Dhost-bios-upgrade=enabled, -Dhost-bios-upgrade=disabled"

PACKAGECONFIG_append_mtjade = " flash_bios"

SYSTEMD_SERVICE_${PN}-updater += "${@bb.utils.contains('PACKAGECONFIG', 'flash_bios', 'obmc-flash-host-bios@.service', '', d)}"

SRC_URI += " \
            file://firmware_update.sh \
            file://0002-BMC-Updater-Support-update-on-BMC-Alternate-device.patch \
           "

RDEPENDS_${PN} += "bash"

do_install_append_mtjade() {
    install -d ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/firmware_update.sh ${D}/usr/sbin/firmware_update.sh
}
