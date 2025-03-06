DESCRIPTION = "Starfive Tools"

inherit native

BBCLASSEXTEND = "native"

LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://jh8100_cst.tar.gz"

S = "${WORKDIR}/jh8100_cst"

FILES:${PN} = "${bindir}/*"

RDEPENDS:${PN} = "bash"

do_compile() {
	oe_runmake -C ${S}
}

do_install() {
	install -d ${D}${bindir}
	install -d ${D}${bindir}/input_files/jh8100
	install -m 0755 ${S}/input_files/jh8100/scpbl_nor.cfg ${D}${bindir}/input_files/jh8100/scpbl_nor.cfg
	install -m 0755 ${S}/mkbif ${D}${bindir}
	install -m 0755 ${S}/create_hdr ${D}${bindir}
}
