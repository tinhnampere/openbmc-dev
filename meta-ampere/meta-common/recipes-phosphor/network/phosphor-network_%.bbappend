PACKAGECONFIG:append = " nic-ethtool"

FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI:append = " \
                  file://0001_avoid_hostnamed_is_triggered.patch \
                 "
