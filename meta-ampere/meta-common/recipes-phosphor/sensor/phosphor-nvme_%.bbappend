FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
             file://0001-sdbusplus-Remove-the-Error-log-in-SMBus-command-send.patch \
             file://0002-Temporary-remove-threshold-check.patch \
           "
