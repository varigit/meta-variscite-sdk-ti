SUMMARY = "Variscite target Yocto install for recovery images."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# For historical reasons, scripts are located outside ${PN} directory
FILESEXTRAPATHS:prepend := "${THISDIR}/../../scripts/variscite:"

INSTALL_SCRIPT ?= "am6_install_yocto.sh"
INSTALL_SCRIPT:am335x-var-som ?= "am3_install_yocto.sh"

RDEPENDS:${PN} = "bash zstd"

SRC_URI = "\
    file://${INSTALL_SCRIPT} \
    file://echos.sh \
"

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${WORKDIR}/${INSTALL_SCRIPT} ${D}${bindir}/install_yocto.sh
    install -m 755 ${WORKDIR}/echos.sh ${D}${bindir}/echos.sh
}

FILES:${PN} = "\
    ${bindir}/install_yocto.sh \
    ${bindir}/echos.sh \
"

COMPATIBLE_MACHINE = "(am62x-var-som|am335x-var-som)"
