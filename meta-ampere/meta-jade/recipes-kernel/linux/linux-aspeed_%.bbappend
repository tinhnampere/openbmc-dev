FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
SRC_URI += " \
            file://defconfig \
            file://mtjade.cfg \
           "

SRCREV="463c3ff9447252a24adca9882bcf2c98822914c0"
