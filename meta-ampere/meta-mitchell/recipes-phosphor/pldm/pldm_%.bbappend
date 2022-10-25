FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN} += "bash"

SRC_URI = "git://github.com/ampere-openbmc/pldm;protocol=https;branch=ampere \
           file://host_eid \
           file://eid_to_name.json \
           file://dbus_to_effecter.json \
          "
SRCREV = "e11c866752add25fbe2057329a25fa0433a36e0f"

SYSTEMD_SERVICE:${PN}:remove = " \
                                pldmSoftPowerOff.service \
                               "
SRC_URI:remove = "file://pldm-softpoweroff"

EXTRA_OEMESON = " \
        -Dtests=disabled \
        -Dsleep-between-get-sensor-reading=10 \
        -Dpoll-sensor-timer-interval=3000 \
        "

do_install:append() {
    install -d ${D}/${datadir}/pldm
    install ${WORKDIR}/host_eid ${D}/${datadir}/pldm/
    install ${WORKDIR}/eid_to_name.json ${D}/${datadir}/pldm/
    install ${WORKDIR}/dbus_to_effecter.json ${D}/${datadir}/pldm/host/
    LINK="${D}${systemd_unitdir}/obmc-host-shutdown@0.target.wants/pldmSoftPowerOff.service"
    rm -f $LINK
    LINK="${D}${systemd_unitdir}/obmc-host-warm-reboot@0.target.wants/pldmSoftPowerOff.service"
    rm -f $LINK
    rm -f ${D}${systemd_unitdir}/system/pldmSoftPowerOff.service
    rm -rf ${D}/${bindir}/pldm-softpoweroff
}
