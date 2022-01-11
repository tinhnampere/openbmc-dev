FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-Fix-wrong-System-Manufacturer-displayed-in-WebUI.patch \
            file://0002-Fix-wrong-factory-reset-page-at-WebUI-is-not-work-on.patch \
            file://0003-Fix-DNS-and-Gateway-loss-information-of-eth1-interfa.patch \
            file://0004-Add-show-info-about-password-policy.patch  \
           "
