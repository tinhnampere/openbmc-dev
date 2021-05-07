FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
           "
PACKAGECONFIG_mtjade = " \
                        adcsensor \
                        fansensor \
                        hwmontempsensor \
                        psusensor \
                        "