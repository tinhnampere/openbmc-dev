FILESEXTRAPATHS_prepend_mtjade := "${THISDIR}/${PN}:"

SRC_URI += " file://nvme_config.json"

SRC_URI += " \
             file://0001-Ampere-phosphor-nvme-Remove-reading-VPD-device.patch \
           "

do_install_append() {
    install -m 0644 -D ${WORKDIR}/nvme_config.json \
                   ${D}/etc/nvme
}
