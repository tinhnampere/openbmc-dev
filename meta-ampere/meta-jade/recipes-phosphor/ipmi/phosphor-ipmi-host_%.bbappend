FILESEXTRAPATHS:append:mtjade := "${THISDIR}/${PN}:"

DEPENDS:append:mtjade = " mtjade-yaml-config"

EXTRA_OECONF:mtjade = " \
    SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/mtjade-yaml-config/ipmi-sensors-${MACHINE}.yaml \
    FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/mtjade-yaml-config/ipmi-fru-read.yaml \
    "
