FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=git;branch=ampere"
SRC_URI += " file://defconfig"
SRC_URI += " file://${MACHINE}.cfg"

SRCREV="670c942fe9dc7c1648901908f826017c2fe1a2b6"
