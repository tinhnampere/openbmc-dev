FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=git;branch=ampere"
SRC_URI += " file://defconfig"
SRC_URI += " file://${MACHINE}.cfg"

SRCREV="55d379445d750c4140e850ab1d47b5e132b1715c"
