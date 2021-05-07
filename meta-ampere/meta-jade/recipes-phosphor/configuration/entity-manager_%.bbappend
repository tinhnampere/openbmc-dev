FILESEXTRAPATHS:prepend:mtjade := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://Mt_Jade.json \
           "

do_install:append:mtjade() {
     install -d ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/Mt_Jade.json ${D}${datadir}/${PN}/configurations
}
