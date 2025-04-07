DESCRIPTION = "Example compound image for Variscite boards"
SECTION = ""

# Note: sw-description is mandatory
SRC_URI = " \
	file://sw-description \
	file://update.sh \
"

inherit swupdate

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# VAR_SWUPDATE_TARGET_IMAGE: Set to primary image packaged in .swu file
VAR_SWUPDATE_TARGET_IMAGE ??= "var-image-swupdate"
# VAR_SWUPDATE_TARGET_IMAGE_FSTYPE: Set to primary image format/extension (i.e. .tar.gz, .tar.zst, etc.)
VAR_SWUPDATE_TARGET_IMAGE_FSTYPE = ".tar.zst"

# VAR_SWUPDATE_TARGET_IMAGE_FILE: Expression to resolve packaged filename based
# on how swupdate packages images in order to update sw-description file
VAR_SWUPDATE_TARGET_IMAGE_FILE = "${VAR_SWUPDATE_TARGET_IMAGE}-${MACHINE}.rootfs${VAR_SWUPDATE_TARGET_IMAGE_FSTYPE}"

# IMAGE_DEPENDS: list of Yocto images that contains a root filesystem
# it will be ensured they are built before creating swupdate image
IMAGE_DEPENDS = "${VAR_SWUPDATE_TARGET_IMAGE}"

# SWUPDATE_IMAGES: list of images that will be part of the compound image
# the list can have any binaries - images must be in the DEPLOY directory
SWUPDATE_IMAGES = " \
	${VAR_SWUPDATE_TARGET_IMAGE_FILE} \
"

# Images can have multiple formats - define which image must be
# taken to be put in the compound image
# This anonymous python function is equivalent to:
# SWUPDATE_IMAGES_FSTYPES["${VAR_SWUPDATE_TARGET_IMAGE}"] = "${VAR_SWUPDATE_TARGET_IMAGE_FSTYPE}"
# however it must be a python function as Bitbake does not expand variables as flag names.
python() {
    d.setVarFlag("SWUPDATE_IMAGES_FSTYPES",
        "VAR_SWUPDATE_TARGET_IMAGE", d.getVar("VAR_SWUPDATE_TARGET_IMAGE_FSTYPE"))
}
