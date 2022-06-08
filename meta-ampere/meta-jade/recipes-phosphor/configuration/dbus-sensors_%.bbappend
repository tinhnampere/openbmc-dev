FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = " intelcpusensor ipmbsensor"
PACKAGECONFIG:append = " nvmesensor amperecpusensor"

SRC_URI:append = " file://0001-Remove-throwing-exception-when-can-not-write-data-to.patch"
