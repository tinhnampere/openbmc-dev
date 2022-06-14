FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append:mtmitchell = " json"

SRC_URI:append:mtmitchell  = "file://events.json \
                              file://fans.json \
                              file://groups.json \
                              file://zones.json \
                              file://monitor.json \
                              file://presence.json \
                              file://phosphor-fan-control@.service \
                              file://phosphor-fan-monitor@.service \
"

do_configure:prepend:mtmitchell () {
        mkdir -p ${S}/control/config_files/${MACHINE}
        cp ${WORKDIR}/events.json ${S}/control/config_files/${MACHINE}/events.json
        cp ${WORKDIR}/fans.json ${S}/control/config_files/${MACHINE}/fans.json
        cp ${WORKDIR}/groups.json ${S}/control/config_files/${MACHINE}/groups.json
        cp ${WORKDIR}/zones.json ${S}/control/config_files/${MACHINE}/zones.json

        mkdir -p ${S}/monitor/config_files/${MACHINE}
        cp ${WORKDIR}/monitor.json ${S}/monitor/config_files/${MACHINE}/config.json

        mkdir -p ${S}/presence/config_files/${MACHINE}
        cp ${WORKDIR}/presence.json ${S}/presence/config_files/${MACHINE}/config.json
}

do_install:append:mtmitchell () {
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/phosphor-fan-monitor@.service ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/phosphor-fan-control@.service ${D}${systemd_system_unitdir}
}
