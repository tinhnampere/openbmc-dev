FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://0001-meta-ampere-pldm-add-the-dbus-interface-for-PldmMess.patch \
                   file://0002-Add-d-bus-OEM-for-boot-progress.patch \
                   file://0003-Add-the-free-instance-id-dbus-interface.patch \
                   file://0004-Add-Numeric-Sensor-Event-signals.patch \
                   file://0005-Add-ReArm-property-to-Chassis-Intrusion.patch \
                   file://0006-Add-HostInterface-D-bus.patch \
                 "
