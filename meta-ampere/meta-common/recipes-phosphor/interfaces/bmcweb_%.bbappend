FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = " \
     -Dinsecure-tftp-update=disabled \
     -Dbmcweb-logging=enabled \
     -Dredfish-bmc-journal=enabled \
     -Dvm-nbdproxy=enabled \
     "

SRC_URI += " \
            file://0001-Re-enable-vm-nbdproxy-for-Virtual-Media.patch \
            file://0002-Redfish-Add-message-registries-for-Ampere-event.patch \
            file://0003-power-control-Fix-power-cycle-issue.patch \
            file://0004-log_services-Workaround-to-fix-the-URL-param-reading.patch \
           "
