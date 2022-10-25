FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://artesyn_psu.json \
	    file://0001-meta-ampere-FruDevice-Support-parsing-Multirecord-UU.patch \
            file://0002-Support-generate-UUID-if-does-not-exist-in-FRU.patch \
           "

TARGET_LDFLAGS += "-luuid"

do_install:append() {
     install -d ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/artesyn_psu.json ${D}${datadir}/${PN}/configurations
}
