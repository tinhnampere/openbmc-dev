FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = "-Dlong-press-time-ms=5000"

SRC_URI += " \
            file://0001-button-handler-Add-button-event-log.patch \
            file://0002-Fix-press-Reset-button-incorrect-behavior.patch \
            file://0003-add-try-catch-to-avoid-get-service-fail.patch \
           "
