FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
SRC_URI += "file://journald.conf"

do_install:append() {
    install -D -m0644 ${WORKDIR}/journald.conf ${D}${systemd_unitdir}/journald.conf.d/00-${PN}.conf
}
