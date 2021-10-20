SUMMARY = "I3C Tools"
DESCRIPTION = "i3c tools"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://README.md;md5=98b44a0db13938e6874f4f1edfe6c689"

inherit meson

SRC_URI = "git://github.com/vitor-soares-snps/i3c-tools.git;protocol=ssh;branch=master"
SRCREV = "5d752038c72af8e011a2cf988b1476872206e706"

S = "${WORKDIR}/git"
