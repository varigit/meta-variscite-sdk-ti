# Copyright (C) 2023 Variscite Ltd
# Released under the MIT license (see COPYING.MIT for the terms)
#
# Usage:
#   This image build a recovery SD card suitible for installing Yocto to eMMC
#   by extending SD_IMAGE and adding the scripts, bootloader, and files
#   necessary to install YOCTO_DEFAULT_IMAGE onto an SD Card.
#
#   The following variables may be overridden in local.conf:
#
#   RECOVERY_SD_NAME:
#       Allows renaming the final image file to something other then
#       var-recovery-sd-image-${MACHINE}. For example:
#       RECOVERY_SD_NAME="mx8m__yocto-kirkstone-5.15-2.0.x-v1.0__android-11.0.0_1.0.0-v1.3"
#
#   SD_IMAGE:
#       The base image to use for the bootable sd card. The full path
#       to the recipe must be provided. For example:
#       SD_IMAGE="recipes-core/images/var-default-image.bb"
#
#   YOCTO_DEFAULT_IMAGE:
#       The image installed to the eMMC by install_yocto.sh
#       Only the name of the image should be provided, for example:
#       YOCTO_DEFAULT_IMAGE="var-default-image"
#

DESCRIPTION = "Variscite recovery SD card image suitable for installing var-default-image on eMMC"
LICENSE = "MIT"

# Optionally override the image name according to RECOVERY_SD_NAME
RECOVERY_SD_NAME ?= "${IMAGE_BASENAME}-${MACHINE}"
IMAGE_LINK_NAME = "${RECOVERY_SD_NAME}"

ROOTFS_POSTPROCESS_COMMAND += ' do_recovery_sdcard;'

# The base image that will be installed on the SD card
SD_IMAGE ?= "recipes-core/images/var-default-image.bb"

# Require the base image that will be installed on the sd card
require ${SD_IMAGE}

# The image to install to eMMC
YOCTO_DEFAULT_IMAGE ?= "${@os.path.splitext(os.path.basename('${SD_IMAGE}'))[0]}"

# Approximate maximum IMAGE_ROOTFS_SIZE to allow for 8GB SD card
# The actual image will be slightly smaller after adjusted by wks
# DEFAULT_EXTRA_SPACE and DEFAULT_OVERHEAD_FACTOR variables.
IMAGE_ROOTFS_MAXSIZE = "${@eval('7420*1024')}"
IMAGE_OVERHEAD_FACTOR = "1"

# Subtract out IMAGE_ROOTFS_EXTRA_SPACE and wks DEFAULT_EXTRA_SPACE and reduce by factor of wks DEFAULT_OVERHEAD_FACTOR
IMAGE_ROOTFS_SIZE_RAW = "${@eval('int((${IMAGE_ROOTFS_MAXSIZE} / 1.3) - (${IMAGE_ROOTFS_EXTRA_SPACE}) - (1024*10))')}"

# Align the image size to 10MB so when scaled by wks DEFAULT_OVERHEAD_FACTOR
# it will remain aligned to 1MB.
IMAGE_ROOTFS_SIZE = "${@eval('${IMAGE_ROOTFS_SIZE_RAW} - (${IMAGE_ROOTFS_SIZE_RAW} % (1024*10))')}"

# Yocto Variables
YOCTO_IMAGE ?=          "${YOCTO_DEFAULT_IMAGE}-${MACHINE}.tar.zst"
YOCTO_IMAGE_PATH ?=     "${DEPLOY_DIR_IMAGE}/${YOCTO_IMAGE}"
YOCTO_SCRIPTS_PATH ?=   "${THISDIR}/../../scripts"
YOCTO_INSTALL_SCRIPT ?= "am6_install_yocto.sh"

do_recovery_sdcard() {
    # Install scripts for eMMC/Nand installation
    install -d ${D}/${bindir}
    install -m 755 ${YOCTO_SCRIPTS_PATH}/variscite/echos.sh ${IMAGE_ROOTFS}/${bindir}/
    install -m 755 ${YOCTO_SCRIPTS_PATH}/variscite/${YOCTO_INSTALL_SCRIPT} \
                    ${IMAGE_ROOTFS}/${bindir}/install_yocto.sh
    # Install boot partition images for eMMC
    install -d ${IMAGE_ROOTFS}/opt/images/Yocto/boot
    install -m 0644 ${DEPLOY_DIR_IMAGE}/tiboot3.bin ${IMAGE_ROOTFS}/opt/images/Yocto/boot
    install -m 0644 ${DEPLOY_DIR_IMAGE}/tispl.bin ${IMAGE_ROOTFS}/opt/images/Yocto/boot
    install -m 0644 ${DEPLOY_DIR_IMAGE}/u-boot.img ${IMAGE_ROOTFS}/opt/images/Yocto/boot
    install -m 0644 ${DEPLOY_DIR_IMAGE}/uEnv.txt ${IMAGE_ROOTFS}/opt/images/Yocto/boot

    # Install Yocto image for eMMC
    if [ ! -f ${YOCTO_IMAGE_PATH} ]; then
        bberror "Could not find Yocto image ${YOCTO_IMAGE_PATH}"
    fi

    install -m 0644 ${YOCTO_IMAGE_PATH} ${IMAGE_ROOTFS}/opt/images/Yocto/rootfs.tar.zst
}

do_rootfs[depends] += "${YOCTO_DEFAULT_IMAGE}:do_image_complete"
COMPATIBLE_MACHINE = "(am62x-var-som)"
