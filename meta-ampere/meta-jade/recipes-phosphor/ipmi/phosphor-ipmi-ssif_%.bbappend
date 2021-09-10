FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/ssifbridge.git;protocol=https;branch=ampere"
SRC_URI += " file://ssifbridge.service"

SRCREV= "753fa07b40217240c91afae085a54e750289c1a2"

do_install:append() {
    cp ${WORKDIR}/ssifbridge.service ${D}${systemd_system_unitdir}/ssifbridge.service
}
