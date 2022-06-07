FILESEXTRAPATHS:prepend := "${THISDIR}/linux-aspeed:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
SRC_URI += " \
            file://defconfig \
            file://ac03.cfg \
            file://0001-mtd-spi-nor-aspeed-force-exit-4byte-mode-when-unbind.patch \
            file://0002-mtd-spi-nor-aspeed-Force-using-4KB-sector-size-for-p.patch \
            file://0003-adc-mux-workaround-add-delay-after-switch-adc-mux.patch \
           "

SRCREV = "b035f27088c4e2490ffd555edc4d4107551ff609"
