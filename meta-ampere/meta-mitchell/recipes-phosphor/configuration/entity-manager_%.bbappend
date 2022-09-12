FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://mt_mitchell_mb.json \
            file://mt_mitchell_bmc.json \
            file://mtmitchell-dcscm_mb.json \
            file://mtmitchell-dcscm_bmc.json \
            file://blacklist.json \
            file://mt_mitchell_bp.json \
           "

do_install:append() {
     install -d ${D}${datadir}/${PN}
     install -m 0444 ${WORKDIR}/blacklist.json ${D}${datadir}/${PN}
     install -d ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/mt_mitchell_mb.json ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/mt_mitchell_bmc.json ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/mt_mitchell_bp.json ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/mtmitchell-dcscm_mb.json ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/mtmitchell-dcscm_bmc.json ${D}${datadir}/${PN}/configurations
     rm -f ${D}${datadir}/${PN}/configurations/nvme_p4000.json
}
