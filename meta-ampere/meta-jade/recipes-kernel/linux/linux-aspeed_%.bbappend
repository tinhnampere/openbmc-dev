FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
SRC_URI += " \
            file://defconfig \
            file://mtjade.cfg \
           "

SRCREV="a9165a5c0026c0cdeded279d8d84f88f396129d6"
KERNEL_VERSION_SANITY_SKIP="1"
