FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG[flash_bios] = "-Dhost-bios-upgrade=enabled, -Dhost-bios-upgrade=disabled"
PACKAGECONFIG[other_update] = "-Dother-upgrade=enabled, -Dother-upgrade=disabled"

PACKAGECONFIG_append_ = " flash_bios"
PACKAGECONFIG_append_mtjade += " other_update"

SYSTEMD_SERVICE_${PN}-updater += "${@bb.utils.contains('PACKAGECONFIG', 'flash_bios', 'obmc-flash-host-bios@.service', '', d)}"

SYSTEMD_SERVICE_${PN}-updater += " \
                                  obmc-update-scp-primary@.service \
                                  obmc-update-scp-secondary@.service \
                                  obmc-update-fru@.service \
				 "

SRC_URI += " \
            file://0001-Add-other-image-update-support.patch \
           "
