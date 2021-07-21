SUMMARY = "A FUSE wrapper that puts the littlefs in user-space"
DESCRIPTION = "A FUSE wrapper that puts the littlefs in user-space"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=96316ea86c6ba156da2aaaaaaff848cc"

inherit autotools pkgconfig

SRC_URI = "git://git@github.com/littlefs-project/littlefs-fuse.git;protocol=ssh;branch=master"
SRCREV = "472c87d598e1899ece2ff86f30657873126a4be7"

DEPENDS = " fuse fuse3"

S = "${WORKDIR}/git"

# pass the Cxx parameter extra to the make call
EXTRA_OEMAKE = "'CC=${CC}' 'RANLIB=${RANLIB}' 'AR=${AR}' 'CFLAGS=${CFLAGS} -I${S}/include' 'BUILDDIR=${S}' 'DESTDIR=${D}'"

INSANE_SKIP:${PN} += "ldflags file-rdeps"

do_compile(){
	cd ${S}
	oe_runmake
}

do_install() {
	install -d ${D}${sbindir}
	install -m 755 ${S}/lfs ${D}/${sbindir}/lfs
}


