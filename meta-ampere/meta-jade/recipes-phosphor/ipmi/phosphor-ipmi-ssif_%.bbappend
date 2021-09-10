FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/ssifbridge.git;protocol=https;branch=ampere"
SRC_URI += " file://ssifbridge.service"

SRCREV= "24c0abc6b8dd768281e82c1e168491fdefc9e6df"

do_install:append() {
    cp ${WORKDIR}/ssifbridge.service ${D}${systemd_system_unitdir}/ssifbridge.service
}
