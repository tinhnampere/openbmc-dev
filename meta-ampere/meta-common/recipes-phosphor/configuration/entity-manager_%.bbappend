FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://ARTESYN_PSU.json \
            file://0001-FruDevice-Support-parsing-Mt.Jade-motherboard-EEPROM.patch \
            file://0002-Support-FruDevice-to-read-UUID-from-FRU-EEPROM.patch \
           "

do_install:append() {
     install -d ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/ARTESYN_PSU.json ${D}${datadir}/${PN}/configurations
}
