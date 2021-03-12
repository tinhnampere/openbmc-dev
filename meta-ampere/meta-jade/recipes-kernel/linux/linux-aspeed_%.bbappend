FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
SRC_URI += " \
            file://defconfig \
            file://mtjade.cfg \
           "

SRCREV="e0dc935b7b349cbae8754731d4cef9cc984bf6cb"
