FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://mt_jade.json \
            file://blacklist.json \
           "

do_install:append() {
     install -d ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/mt_jade.json ${D}${datadir}/${PN}/configurations
     install -d ${D}${datadir}/${PN}
     install -m 0444 ${WORKDIR}/blacklist.json ${D}${datadir}/${PN}
}
