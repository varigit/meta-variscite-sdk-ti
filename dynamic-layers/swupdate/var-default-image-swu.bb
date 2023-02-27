DESCRIPTION = "Example compound image for Variscite boards"
SECTION = ""

# Note: sw-description is mandatory
SRC_URI = " \
	file://sw-description \
	file://update.sh \
"

SRC_URI:append:am62x-var-som = " \
	file://${DEPLOY_DIR_IMAGE}/tiboot3.bin \
	file://${DEPLOY_DIR_IMAGE}/tispl.bin \
	file://${DEPLOY_DIR_IMAGE}/u-boot.img \
	file://${DEPLOY_DIR_IMAGE}/uEnv.txt \
"

inherit swupdate

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# IMAGE_DEPENDS: list of Yocto images that contains a root filesystem
# it will be ensured they are built before creating swupdate image
IMAGE_DEPENDS = "var-default-image"

# SWUPDATE_IMAGES: list of images that will be part of the compound image
# the list can have any binaries - images must be in the DEPLOY directory
SWUPDATE_IMAGES = " \
	var-default-image \
"

# Images can have multiple formats - define which image must be
# taken to be put in the compound image
SWUPDATE_IMAGES_FSTYPES[var-default-image] = ".tar.zst"
