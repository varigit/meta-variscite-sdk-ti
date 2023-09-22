#!/bin/sh

. /usr/bin/echos.sh

BOARD=am335x-var-som
INSTALL_OS="Yocto"
IMGS_PATH="${IMGS_PATH:=/opt/images/Yocto}"

MLO_IMAGE=MLO-nand
UBOOT_IMAGE=u-boot.img-nand
KERNEL_IMAGE=zImage
DTB_IMAGE=var-som-am33.dtb
ROOTFS_IMAGE=rootfs.ubi

check_image()
{
	if [[ ! -f $1 ]] ; then
		red_bold_echo "ERROR: \"$1\" does not exist"
		exit 1
	fi
}

check_images()
{
	# Boot Images
	check_image $IMGS_PATH/boot/$MLO_IMAGE
	check_image $IMGS_PATH/boot/$UBOOT_IMAGE
	check_image $IMGS_PATH/boot/$KERNEL_IMAGE
	check_image $IMGS_PATH/boot/$DTB_IMAGE

	# ROOTFS
	check_image $IMGS_PATH/$ROOTFS_IMAGE
}

delete_nand()
{
	echo
	blue_underlined_bold_echo "Deleting NAND partitions"

	flash_erase /dev/mtd0 0 0 > /dev/null
	flash_erase /dev/mtd1 0 0 > /dev/null
	flash_erase /dev/mtd2 0 0 > /dev/null
	flash_erase /dev/mtd3 0 0 > /dev/null
	flash_erase /dev/mtd4 0 0 > /dev/null
	flash_erase /dev/mtd5 0 0 > /dev/null
	flash_erase /dev/mtd6 0 0 > /dev/null
	flash_erase /dev/mtd7 0 0 > /dev/null
	flash_erase /dev/mtd8 0 0 > /dev/null
	flash_erase /dev/mtd9 0 0 > /dev/null
}

install_bootloader_to_nand()
{
	echo
	blue_underlined_bold_echo "Installing bootloader"

	nandwrite -p /dev/mtd0 $IMGS_PATH/boot/$MLO_IMAGE > /dev/null
	nandwrite -p /dev/mtd1 $IMGS_PATH/boot/$MLO_IMAGE > /dev/null
	nandwrite -p /dev/mtd2 $IMGS_PATH/boot/$MLO_IMAGE > /dev/null
	nandwrite -p /dev/mtd3 $IMGS_PATH/boot/$MLO_IMAGE > /dev/null

	nandwrite -p /dev/mtd5 $IMGS_PATH/boot/$UBOOT_IMAGE > /dev/null
}

install_kernel_to_nand()
{
	echo
	blue_underlined_bold_echo "Installing kernel"
	nandwrite -p /dev/mtd8 $IMGS_PATH/boot/$KERNEL_IMAGE > /dev/null

	echo
	blue_underlined_bold_echo "Installing DTB"
	nandwrite -p /dev/mtd4 $IMGS_PATH/boot/$DTB_IMAGE > /dev/null
}

install_rootfs_to_nand()
{
	echo
	blue_underlined_bold_echo "Installing rootfs"
	ubiformat /dev/mtd9 -f $IMGS_PATH/$ROOTFS_IMAGE -s 2048 -O 2048
	sync
}

set_fw_env_config_to_nand()
{
	echo
	blue_underlined_bold_echo "Fixup fw_env.config on NAND"

	# mount the rootfs partition@9
	ubi0_mount_prefix=/run/media/ubi0_rootfs
	ubiattach /dev/ubi_ctrl -m 9 -O 2048
	mkdir ${ubi0_mount_prefix}
	mount -t ubifs ubi0:rootfs ${ubi0_mount_prefix}

	# update the environment in fw_env.config
	sed -i "/mmcblk/ s/^#*/#/" ${ubi0_mount_prefix}/etc/fw_env.config
	sed -i "s/#*\/dev\/mtd/\/dev\/mtd/" ${ubi0_mount_prefix}/etc/fw_env.config
	ln -sf u-boot-initial-env-nand ${ubi0_mount_prefix}/etc/u-boot-initial-env

	# unmount the rootfs partition
	umount ${ubi0_mount_prefix}
	rmdir ${ubi0_mount_prefix}
	ubidetach /dev/ubi_ctrl -m 9
	sync
}


finish()
{
	echo
	blue_bold_echo "${INSTALL_OS} installed successfully"
	exit 0
}

#################################################
#           Execution starts here               #
#################################################

blue_underlined_bold_echo "*** Variscite AM33 ${INSTALL_OS} NAND Recovery ***"
echo

printf "Board: "
blue_bold_echo $BOARD

printf "OS to install: "
blue_bold_echo $INSTALL_OS

printf "Installing to internal storage device: "
blue_bold_echo NAND

check_images
delete_nand
install_bootloader_to_nand
install_kernel_to_nand
install_rootfs_to_nand
set_fw_env_config_to_nand
finish
