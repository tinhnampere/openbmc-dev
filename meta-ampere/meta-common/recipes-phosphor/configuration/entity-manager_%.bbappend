FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://artesyn_psu.json \
           "

do_install:append() {
     install -d ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/artesyn_psu.json ${D}${datadir}/${PN}/configurations
}
