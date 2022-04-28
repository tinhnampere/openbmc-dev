FILESEXTRAPATHS:prepend := "${THISDIR}/linux-aspeed:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
KERNEL_VERSION_SANITY_SKIP="1"
SRC_URI += " \
            file://defconfig \
            file://ac03.cfg \
           "

SRCREV = "a9165a5c0026c0cdeded279d8d84f88f396129d6"
