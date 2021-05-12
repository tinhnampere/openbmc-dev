FILESEXTRAPATHS:prepend:mtjade := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://Mt_Jade.json \
            file://0001-FruDevice-Support-parsing-Mt.Jade-motherboard-EEPROM.patch \
           "

do_install:append:mtjade() {
     install -d ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/Mt_Jade.json ${D}${datadir}/${PN}/configurations
}
