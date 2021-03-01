FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " file://0001-correct-the-hard-reset-command.patch \
             file://0002-Support-Get-System-Interface-Capabilities-Command.patch \
           "
