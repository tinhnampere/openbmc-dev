FILESEXTRAPATHS:prepend:mtjade := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://0001-adcsensor-Match-the-sensor-device-name.patch \
            file://0002-adcsensor-Add-support-DevName-option.patch \
            file://0003-amperecpu-Add-Ampere-CPU-daemon.patch \
            file://0004-amperecpu-Scan-CPU-sensors-in-the-first-power-on.patch \
            file://0005-amperecpu-Support-PresenceGpio-option.patch \
            file://0006-Dbus-sensors-restructure-the-code-handle-PowerState-.patch \
            file://0007-ADCSensor-FanSensor-Support-ChassisState-attribute.patch \
           "
PACKAGECONFIG:mtjade = " \
                        adcsensor \
                        fansensor \
                        hwmontempsensor \
                        psusensor \
                        amperecpusensor \
                        "
PACKAGECONFIG[amperecpusensor] = "-Dampere-cpu=enabled, -Dampere-cpu=disabled"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains('PACKAGECONFIG', 'amperecpusensor', \
                                               'xyz.openbmc_project.amperecpusensor.service', \
                                               '', d)}"
