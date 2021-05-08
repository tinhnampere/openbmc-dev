FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://Mt_Jade.json"
SRC_URI += " \
            file://0001-EntityManager-Add-new-platform-Mt.Jade.patch \
            file://xyz.openbmc_project.FruDevice.service \
           "

do_install_append_mtjade() {
     install -d ${D}/usr/share/entity-manager/configurations
     install -m 0444 ${WORKDIR}/*.json ${D}/usr/share/entity-manager/configurations
     install -d ${D}${systemd_system_unitdir}
     install -m 0644 ${WORKDIR}/xyz.openbmc_project.FruDevice.service ${D}${systemd_system_unitdir}
}