FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
SRC_URI += " \
            file://defconfig \
            file://ampere.cfg \
            file://0001-mtd-spi-nor-aspeed-force-exit-4byte-mode-when-unbind.patch \
           "

SRCREV = "3a22810f96c871506405815cc04b961d9cf788b6"
