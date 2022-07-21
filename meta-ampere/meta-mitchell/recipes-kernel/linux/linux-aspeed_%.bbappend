FILESEXTRAPATHS:prepend := "${THISDIR}/linux-aspeed:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
KERNEL_VERSION_SANITY_SKIP="1"
SRC_URI += " \
            file://defconfig \
            file://ac03.cfg \
            file://0001-mtd-spi-nor-aspeed-force-exit-4byte-mode-when-unbind.patch \
            file://0002-mtd-spi-nor-aspeed-Force-using-4KB-sector-size-for-p.patch \
            file://0003-adc-mux-workaround-add-delay-after-switch-adc-mux.patch \
           "

SRCREV = "f9c38e1ca0da284b378f97b9de89dd3803c2eee1"
