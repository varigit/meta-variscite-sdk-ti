# Copyright (C) 2023 Variscite Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Variscite bootable recovery SD card image used for installing \
    various images on the eMMC."
LICENSE = "MIT"

# The base of the running SD recovery image defaults to var-default-image.
# VAR_RECOVERY_SD_IMAGE can be overridden in local.conf or other conf files.
VAR_RECOVERY_SD_IMAGE ?= "recipes-core/images/var-default-image.bb"

# The target rootfs that is programmed to the eMMC also defaults to var-default-image.
# VAR_RECOVERY_TARGET_ROOTFS can be overridden via an environment variable or in
# local.conf or other conf files.
VAR_RECOVERY_TARGET_ROOTFS ?= "var-default-image"


# The recovery SD image is dependent on U-Boot components
VAR_RECOVERY_DEPENDS = "\
   u-boot-variscite \
"

# Package the imx-boot generated file in the SD image
VAR_RECOVERY_IMAGES = "\
    tiboot3.bin \
	tispl.bin \
	u-boot.img \
	uEnv.txt \
"

VAR_RECOVERY_IMAGES:am335x-var-som = "\
	MLO-nand \
	u-boot.img-nand \
	zImage \
	var-som-am33.dtb \
"

# The file must then be renamed to follow the install_yocto.sh standard name.
VAR_RECOVERY_IMAGE_SUBDIR[tiboot3.bin] = "boot"
VAR_RECOVERY_IMAGE_SUBDIR[tispl.bin] = "boot"
VAR_RECOVERY_IMAGE_SUBDIR[u-boot.img] = "boot"
VAR_RECOVERY_IMAGE_SUBDIR[uEnv.txt] = "boot"
VAR_RECOVERY_IMAGE_SUBDIR[MLO-nand] = "boot"
VAR_RECOVERY_IMAGE_SUBDIR[u-boot.img-nand] = "boot"
VAR_RECOVERY_IMAGE_SUBDIR[zImage] = "boot"
VAR_RECOVERY_IMAGE_SUBDIR[var-som-am33.dtb] = "boot"

# Use the var-recovery bbclass
inherit var-recovery

COMPATIBLE_MACHINE = "(am62x-var-som|am335x-var-som)"

# Removing default ubi creation for this image
IMAGE_FSTYPES:remove:am335x-var-som = "ubi"
