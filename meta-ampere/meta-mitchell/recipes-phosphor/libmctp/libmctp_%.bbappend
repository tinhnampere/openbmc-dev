FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "git://github.com/ampere-openbmc/libmctp;protocol=https;branch=ampere \
           file://${MACHINE}_default \
           file://eid.cfg \
          "
SRCREV = "4f4c4ab89a81d73093a6fa5de3b4c9c83036e1f2"

FILES:${PN} += "${datadir}/mctp/eid.cfg"

do_compile:prepend() {
    cp "${WORKDIR}/${MACHINE}_default" "${WORKDIR}/default"
}

do_install:append() {
    install -d ${D}/${datadir}/mctp
    install ${WORKDIR}/eid.cfg ${D}/${datadir}/mctp/eid.cfg
}
