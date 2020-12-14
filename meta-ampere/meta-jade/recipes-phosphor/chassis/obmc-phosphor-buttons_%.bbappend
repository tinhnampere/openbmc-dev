FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

EXTRA_OECMAKE += "-DLONG_PRESS_TIME_MS=5000"

SRC_URI += " file://0001-button-handler-Add-button-event-log.patch "
