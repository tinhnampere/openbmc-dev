FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
SRC_URI += "file://systemd-timedated.service"

#Overwrite the default systemd-timedated.service with a version that qcquires
#    and releases the rtc_lock GPIO_Z3
do_install:append() {
	cp ${WORKDIR}/systemd-timedated.service ${D}${systemd_system_unitdir}/systemd-timedated.service
}
