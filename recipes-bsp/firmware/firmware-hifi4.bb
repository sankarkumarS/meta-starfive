DESCRIPTION = "HiFi4 Firmware for JH8100"

LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

S:starfive-jh8100 = "${WORKDIR}"

INHIBIT_SYSROOT_STRIP = "1"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

SRC_URI:starfive-jh8100 = "file://hifi4_elf"

INSANE_SKIP:${PN} = "arch"

FILES:${PN} += "${libdir}/firmware/*"

do_install:starfive-jh8100() {
	install -d ${D}${libdir}/firmware
        install -m 0644 ${S}/hifi4_elf ${D}${libdir}/firmware
}
