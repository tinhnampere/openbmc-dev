FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
SRC_URI += " \
            file://defconfig \
            file://mtjade.cfg \
           "

SRCREV="b035f27088c4e2490ffd555edc4d4107551ff609"
