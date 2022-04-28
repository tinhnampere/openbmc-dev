FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://ampere.cfg \
            file://arch/arm/dts \
            file://0001-dts-add-Mt.Mitchell.patch \
           "

do_configure:append (){
    cp -rf "${WORKDIR}/arch/arm/dts/" "${S}/arch/arm/"
}
