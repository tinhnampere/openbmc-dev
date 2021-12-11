FILESEXTRAPATHS:append:mtjade := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-aspeed-support-passing-system-reset-status-to-kernel.patch \
           "
