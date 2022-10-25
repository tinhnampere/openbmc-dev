FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/ssifbridge.git;protocol=https;branch=ampere"
SRC_URI += " file://ssifbridge.service"

SRCREV= "3e8448479490d9f98d3e958a080de241aceb8e75"

do_install:append() {
    cp ${WORKDIR}/ssifbridge.service ${D}${systemd_system_unitdir}/ssifbridge.service
}
