FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = " \
     -Dinsecure-tftp-update=disabled \
     -Dbmcweb-logging=enabled \
     -Dredfish-bmc-journal=enabled \
     -Dhttp-body-limit=65 \
     -Dvm-nbdproxy=enabled \
     "

SRC_URI += " \
            file://0001-Re-enable-vm-nbdproxy-for-Virtual-Media.patch \
            file://0002-Redfish-Add-message-registries-for-Ampere-event.patch \
           "
