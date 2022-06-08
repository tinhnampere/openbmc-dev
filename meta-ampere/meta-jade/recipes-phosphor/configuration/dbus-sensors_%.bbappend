FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = " cpusensor ipmbsensor"
PACKAGECONFIG:append = "amperecpusensor"

SRC_URI:append:mtjade1u = " file://0001-Remove-throwing-exception-when-can-not-write-data-to.patch"