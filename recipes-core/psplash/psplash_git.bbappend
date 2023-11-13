FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
	file://0001-psplash-Change-colors-for-the-Variscite-Yocto-logo.patch \
	file://psplash-bar.png \
"

SPLASH_IMAGES = "file://psplash-poky.png;outsuffix=default"

do_configure:prepend() {
	cp ${WORKDIR}/*.png ${S}/base-images
}
