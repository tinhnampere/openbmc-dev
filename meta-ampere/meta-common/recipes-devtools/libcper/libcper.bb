SUMMARY = "CPER Library"
DESCRIPTION = "CPER Lib"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://README.md;md5=be4449b7dd5a7460fe1c6fe07b0de248"

inherit cmake pkgconfig

DEPENDS = "json-c"


SRC_URI = "git://git.gitlab.arm.com/server_management/libcper.git;protocol=https;branch=master"
SRCREV = "${AUTOREV}"


do_configure[network] =  "1"
do_compile[network] = "1"

EXTRA_OECMAKE = " \
                -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
                "

TARGET_CFLAGS += "-fno-stack-protector"

INSANE_SKIP:${PN} = "ldflags"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
SOLIBS = ".so"
FILES_SOLIBSDEV = ""

S = "${WORKDIR}/git"

do_compile:prepend() {
    cp -r ${WORKDIR}/git/specification ${WORKDIR}/build/
}

do_install() {
    install -d ${D}${sbindir}
    install -d ${D}${libdir}

    install -m 0755 ${WORKDIR}/build/lib/libb64c.so ${D}${libdir}
    install -m 0755 ${WORKDIR}/build/bin/cper-convert ${D}${sbindir}
    install -m 0755 ${WORKDIR}/build/bin/cper-generate ${D}${sbindir}
    install -m 0755 ${WORKDIR}/build/bin/json_parse ${D}${sbindir}
}
