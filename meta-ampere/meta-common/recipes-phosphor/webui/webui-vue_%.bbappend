FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-Fix-wrong-System-Manufacturer-displayed-in-WebUI.patch \
            file://0002-Fix-wrong-factory-reset-page-at-WebUI-is-not-work-on.patch \
           "
