FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-FruDevice-Support-parsing-Mt.Jade-motherboard-EEPROM.patch \
            file://0002-Support-FruDevice-to-read-UUID-from-FRU-EEPROM.patch \
           "
