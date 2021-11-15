FILESEXTRAPATHS:prepend:mtjade := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://Mt_Jade.json \
            file://blacklist.json \
           "

do_install:append:mtjade() {
     install -d ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/Mt_Jade.json ${D}${datadir}/${PN}/configurations
     install -d ${D}${datadir}/${PN}
     install -m 0444 ${WORKDIR}/blacklist.json ${D}${datadir}/${PN}
}
