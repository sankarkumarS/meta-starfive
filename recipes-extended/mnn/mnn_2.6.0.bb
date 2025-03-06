DESCRIPTION = "MNN is a blazing fast, lightweight deep learning framework, battle-tested by business-critical use cases in Alibaba"
HOMEPAGE = "www.mnn.zone"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://README.md;startline=124;endline=125;md5=866c85dec0fa0932d17067810bf0e08c"

SRC_URI = " \
    git://github.com/alibaba/MNN.git;branch=master;protocol=https \
    file://run-ptest \
    file://0001-fix-build-with-gcc-13.patch \
"
SRCREV = "d20f37fd7134127dde9201e74d38dc0c08d4a096"

S = "${WORKDIR}/git"

inherit cmake ptest

EXTRA_OECMAKE = "-DMNN_BUILD_TEST=1"

FILES:${PN} += "${libdir}/MNN*"

SOLIBS = ".so"
FILES_SOLIBSDEV = ""

RDEPENDS:${PN} += "libstdc++"

do_install_ptest() {
        install ${B}/run_test.out ${D}${PTEST_PATH}
}
