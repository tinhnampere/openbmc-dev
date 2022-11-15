FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
           file://0001-Add-compact-numeric-sensor-PDR-definitions.patch \
           file://0002-Add-effecter-aux-name-PDR-struct.patch \
           file://0003-requester-Add-encode-decode-for-PollForPlatformEvent.patch \
           file://0004-responder-Add-encode-decode-for-PollForPlatformEvent.patch \
           file://0005-Add-Ampere-API-PldmMessagePollEventSignal.patch \
           file://0006-Add-encode-decode-for-EventMessageSupported.patch \
           file://0007-Add-encode-decode-for-EventMessageBufferSize.patch \
           file://0008-pldmtool-fix-pldmtool-stuck-in-waiting-forever-respo.patch \
          "
