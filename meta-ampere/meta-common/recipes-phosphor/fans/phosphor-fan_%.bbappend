FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " prevent-host-control"
# The disable host control when the fan sensors are not created.
PACKAGECONFIG[prevent-host-control] = "-Dprevent-host-control=enabled"

SRC_URI += " \
            file://0001-set-fan-presence-condition-500-rpm.patch \
            file://0002-add-disabled-host-control-option.patch \
           "
