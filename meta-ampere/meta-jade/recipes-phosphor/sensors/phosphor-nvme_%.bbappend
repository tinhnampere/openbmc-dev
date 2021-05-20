FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " file://nvme_config.json"
SRC_URI += " \
             file://0001-sdbusplus-Remove-the-Error-log-in-SMBus-command-send.patch \
           "

do_install:append() {
    install -m 0644 -D ${WORKDIR}/nvme_config.json \
                   ${D}/etc/nvme
}
