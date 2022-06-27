FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = " cpusensor ipmbsensor"
PACKAGECONFIG:append = " nvmesensor"