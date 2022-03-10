FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=git;branch=ampere"
SRC_URI += " file://defconfig"
SRC_URI += " file://${MACHINE}.cfg"

SRCREV="24c4f44a2f114276c3f6035ae417d7a04ece21fe"
