FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://ampere.cfg \
            file://arch/arm/dts \
            file://0001-dts-add-Mt.Mitchell.patch \
            file://0002-mtd-spi-spi-nor-core-Check-the-4byte-opcode-supporti.patch \
           "

do_configure:append (){
    cp -rf "${WORKDIR}/arch/arm/dts/" "${S}/arch/arm/"
}
