inherit obmc-phosphor-systemd

FILESEXTRAPATHS:prepend:mtjade := "${THISDIR}/${PN}:"

HOSTIPMI_PROVIDER_LIBRARY:remove:mtjade = "libstrgfnhandler.so"

do_install:append:mtjade () {
	rm -rf ${D}${libdir}/ipmid-providers
}
