FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://virtual_sensor_config.json"
SRC_URI += "file://0001-Add-catch-exception-when-the-sensor-value.patch"

do_install_append_mtjade() {
    install -m 0644 ${WORKDIR}/virtual_sensor_config.json ${D}${datadir}/phosphor-virtual-sensor/
}

