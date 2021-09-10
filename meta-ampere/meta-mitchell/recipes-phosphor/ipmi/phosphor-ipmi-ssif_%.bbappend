FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/ampere-openbmc/ssifbridge.git;protocol=https;branch=ampere"
SRC_URI += " file://ssifbridge.service"

SRCREV= "9dd7e1372f6259b447d72e5cf0ca09a236c40a76"

do_install:append() {
    cp ${WORKDIR}/ssifbridge.service ${D}${systemd_system_unitdir}/ssifbridge.service
}
