FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
SRC_URI += " \
            file://defconfig \
            file://ampere.cfg \
            file://0001-mtd-spi-nor-aspeed-force-exit-4byte-mode-when-unbind.patch \
            file://0002-mtd-spi-nor-aspeed-Force-using-4KB-sector-size-for-p.patch \
           "

SRCREV = "e0dc935b7b349cbae8754731d4cef9cc984bf6cb"
