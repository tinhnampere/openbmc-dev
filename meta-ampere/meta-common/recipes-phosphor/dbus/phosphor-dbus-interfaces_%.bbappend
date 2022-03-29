FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://0001-meta-ampere-pldm-add-the-dbus-interface-for-PldmMess.patch \
                 "
