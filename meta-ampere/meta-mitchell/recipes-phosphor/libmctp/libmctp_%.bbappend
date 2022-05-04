FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "git://github.com/ampere-openbmc/libmctp;protocol=https;branch=ampere \
           file://${MACHINE}_default \
           file://eid.cfg \
          "
SRCREV = "784695d99e592354440f08499a8eabad7a33818c"

FILES:${PN} += "${datadir}/mctp/eid.cfg"

do_compile:prepend() {
    cp "${WORKDIR}/${MACHINE}_default" "${WORKDIR}/default"
}

do_install:append() {
    install -d ${D}/${datadir}/mctp
    install ${WORKDIR}/eid.cfg ${D}/${datadir}/mctp/eid.cfg
}
