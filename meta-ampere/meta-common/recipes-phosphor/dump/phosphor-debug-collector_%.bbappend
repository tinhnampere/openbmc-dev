FILESEXTRAPATHS:prepend := "${THISDIR}/phosphor-debug-collector:"

SRC_URI += " \
            file://0001-Add-CPER-Log-and-Crashdump-support-in-FaultLog.patch \
            file://0002-Remove-fault-log-file-when-exceed-maximum-fault-log.patch \
           "

EXTRA_OEMESON = " \
        -DMAX_TOTAL_FAULT_LOG_ENTRIES=100 \
        -DMAX_NUM_SAVED_CPER_LOG_ENTRIES=10 \
        "
