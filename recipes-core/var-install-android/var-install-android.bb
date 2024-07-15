SUMMARY = "Variscite target Android install for recovery images."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "parted-native zstd mtools-native"
RDEPENDS:${PN} = "bash zstd"

ANDROID_IMAGE_FILENAME = "am62__yocto-kirkstone-6.1.46_09.01.00.08-v1.0__android-14_09.02.00-v1.0.wic"
ANDROID_IMAGE_FOLDER = "VAR-SOM-AM62"
ANDROID_IMAGE_CKSUM = "1b219a6f52ad8aa4fbcf7a4f78e8acb8951e18e289390c2b19e06a0aef2bb5d8"

SRC_URI = "https://variscite-public.nyc3.cdn.digitaloceanspaces.com/${ANDROID_IMAGE_FOLDER}/Software/${ANDROID_IMAGE_FILENAME}.zst;sha256sum=${ANDROID_IMAGE_CKSUM}"

do_install() {
	install -d ${D}${bindir}
	install -d ${D}/opt/images
	wic cp  ${WORKDIR}/${ANDROID_IMAGE_FILENAME}:2${bindir}/install_android.sh ${D}${bindir}/install_android.sh
	chmod 755 ${D}${bindir}/install_android.sh
	chown root:root ${D}${bindir}/install_android.sh
	wic cp  ${WORKDIR}/${ANDROID_IMAGE_FILENAME}:2/opt/images/Android ${D}/opt/images/
	chown -R root:root ${D}/opt/images/Android
}

FILES:${PN} = "\
	${bindir}/install_android.sh \
	/opt/images/Android/* \
"

INSANE_SKIP:${PN} += "arch"

COMPATIBLE_MACHINE = "am62x-var-som"
