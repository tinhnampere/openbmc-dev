FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-amperecpu-Add-Ampere-CPU-daemon.patch \
            file://0002-amperecpu-Scan-CPU-sensors-in-the-first-power-on.patch \
            file://0003-amperecpu-Support-PresenceGpio-option.patch \
            file://0004-Dbus-sensors-restructure-the-code-handle-PowerState-.patch \
            file://0005-ADCSensor-FanSensor-Support-ChassisState-attribute.patch \
            file://0006-amperecpu-Support-label-AddAssoc-option.patch \
           "

PACKAGECONFIG[amperecpusensor] = "-Dampere-cpu=enabled, -Dampere-cpu=disabled"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains('PACKAGECONFIG', 'amperecpusensor', \
                                               'xyz.openbmc_project.amperecpusensor.service', \
                                               '', d)}"
