FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://0002-hasher-symlink.patch"

SRCREV = "805d2dd0bec9ddb9d714afd4e181cee88c13adb0"

PACKAGECONFIG = " testapp apps"

do_install:append(){
   cd ${WORKDIR}/image/usr/libexec/libkcapi
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/md5sum
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha1hmac
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha1sum
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha224hmac
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha224sum
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha256hmac
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha256sum
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha384hmac
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha384sum
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha3sum
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha512hmac
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sha512sum
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sm3hmac
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/sm3sum
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/fipscheck
   ln -srf ../../bin/kcapi-hasher ${WORKDIR}/image/usr/libexec/libkcapi/fipshmac
}
