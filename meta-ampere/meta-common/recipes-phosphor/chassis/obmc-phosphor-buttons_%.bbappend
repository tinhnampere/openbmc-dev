FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
SRCREV = "eea8a4a5f764d61cb96b14867a78f7e975e75656"

EXTRA_OECMAKE += "-DLONG_PRESS_TIME_MS=5000"

SRC_URI += " \
            file://0001-button-handler-Add-button-event-log.patch \
            file://0002-Fix-press-Reset-button-incorrect-behavior.patch \
           "
