FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

EXTRA_OEMESON_append = " \
     -Dinsecure-tftp-update=enabled \
     -Dbmcweb-logging=enabled \
     -Dredfish-bmc-journal=enabled \
     -Dvm-nbdproxy=enabled \
     "

SRC_URI += " \
            file://0001-Redfish-Add-message-registries-for-Ampere-event.patch \
            file://0002-Re-enable-vm-nbdproxy-for-Virtual-Media.patch \
           "
