#!/bin/bash -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "/usr/bin/echos.sh" ]; then
	. /usr/bin/echos.sh
elif [ -f "${SCRIPT_DIR}/echos.sh" ]; then
	. ${SCRIPT_DIR}/echos.sh
fi

# Weakly initialize INSTALL_OS variable if it is empty or undefined
# allowing it to be overriden by the environment
INSTALL_OS="${INSTALL_OS:=Yocto}"

detect_OS()
{
	# Detect OS when the script is running from Yocto/Debian target
	#
	# Weakly initialize IMGS_PATH variable if it is empty or undefined
	# allowing it to be overriden by the environment
	#
	# In the case the script is running from x86 develop machine, nothing todo
	# because it is sourced (e.g. by make_weston_sdcard_am6() function in the
	# weston_rootfs.sh) and the INSTALL_OS variable is overriden
	#
	if grep -q 'PRETTY_NAME="Arago' /etc/os-release > /dev/null 2>&1; then
		INSTALL_OS="Yocto"
		IMGS_PATH="${IMGS_PATH:=/opt/images/Yocto}"
	elif grep -q 'PRETTY_NAME="Debian' /etc/os-release > /dev/null 2>&1; then
		INSTALL_OS="Debian"
		IMGS_PATH="${IMGS_PATH:=/opt/images/Debian}"
	fi
}

if [ -z "${PART+x}" ]; then
    PART="p"
fi
UPDATE_ENVTOOLS="yes"
ROOTFSPART=2
ROOTFS_IMAGE=rootfs.tar.zst
BOOT_PART_SIZE_MB="40"
UBOOT_ENV_START_MB=$((BOOT_PART_SIZE_MB + 3))
ROOTFS_START_MB="$((BOOT_PART_SIZE_MB + 4))"
ROOTFS_START_SECTOR=$((ROOTFS_START_MB * 1024 * 1024 / 512))

check_board()
{
	DEBIAN_IMAGES_TO_ROOTFS_POINT=""

	if grep -q "AM62X" /sys/devices/soc0/family > /dev/null 2>&1; then
		BOARD=am62x-var-som
		EMMC_BLOCK=mmcblk0
		SD_BLOCK=mmcblk1
	elif uname -m | grep -qi "x86"; then
		BOARD=x86
		UPDATE_ENVTOOLS="no"
		if [ "${INSTALL_OS}" = "Debian" ]; then
			DEBIAN_IMAGES_TO_ROOTFS_POINT="/opt/images/Debian"
		fi
		red_bold_echo "Warning: running from x86 machine. Make sure you know what you're doing to avoid data loss"
		if [[ -z "${EMMC_BLOCK}" ]]; then
			red_bold_echo "ERROR: EMMC_BLOCK is not set."
			exit 1
		fi
	else
		red_bold_echo "ERROR: Unsupported board"
		exit 1
	fi

	if [[ ! -b /dev/${EMMC_BLOCK} ]] ; then
		red_bold_echo "ERROR: Can't find eMMC device (/dev/${EMMC_BLOCK})."
		red_bold_echo "Please verify you are using the correct options for your SOM."
		exit 1
	fi

	DRIVE="/dev/${EMMC_BLOCK}"
}

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
	check_image $IMGS_PATH/boot/tiboot3.bin
	check_image $IMGS_PATH/boot/tispl.bin
	check_image $IMGS_PATH/boot/u-boot.img
	check_image $IMGS_PATH/boot/uEnv.txt

	# ROOTFS
	check_image $IMGS_PATH/$ROOTFS_IMAGE
}

delete_emmc()
{
	echo
	blue_underlined_bold_echo "Deleting current partitions"

	umount /dev/${EMMC_BLOCK}${PART}* 2>/dev/null || true

	for ((i=1; i<=16; i++)); do
		if [[ -e /dev/${EMMC_BLOCK}${PART}${i} ]]; then
			dd if=/dev/zero of=/dev/${EMMC_BLOCK}${PART}${i} bs=1M count=1 2>/dev/null || true
		fi
	done

	sync

	# Zero out first 10MB
	dd if=/dev/zero of=/dev/${EMMC_BLOCK} bs=1M count=10

	# Zero out environment
	dd if=/dev/zero of=/dev/${EMMC_BLOCK} bs=1M count=1 seek=${UBOOT_ENV_START_MB} 2>/dev/null || true

	sync; sleep 1
}

create_emmc_parts()
{
	dd if=/dev/zero of=$DRIVE bs=1024 count=1024

	SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`
	echo DISK SIZE - $SIZE bytes

	(
	 echo n; echo p; echo 1; echo; echo +${BOOT_PART_SIZE_MB}M; \
	 echo n; echo p; echo 2; echo ${ROOTFS_START_SECTOR}; echo; \
	 echo t; echo 1; echo c; echo a; echo 1; \
	 echo p; echo w;
	) | fdisk -u /dev/${EMMC_BLOCK} > /dev/null

	sync; sleep 1
	fdisk -u -l /dev/${EMMC_BLOCK}
}

create_emmc_swupdate_parts()
{
	echo
	blue_underlined_bold_echo "Creating new partitions"

	TOTAL_SECTORS=`cat /sys/block/${EMMC_BLOCK}/size`
	SECT_SIZE_BYTES=`cat /sys/block/${EMMC_BLOCK}/queue/hw_sector_size`

	ROOTFS1_PART_START=${ROOTFS_START_SECTOR}

	DATA_SIZE_BYTES=$((DATA_SIZE * 1024 * 1024))
	DATA_PART_SIZE=$((DATA_SIZE_BYTES / SECT_SIZE_BYTES))

	ROOTFS1_PART_SIZE=$((( TOTAL_SECTORS - ROOTFS1_PART_START - DATA_PART_SIZE ) / 2))
	ROOTFS2_PART_SIZE=$ROOTFS1_PART_SIZE

	ROOTFS2_PART_START=$((ROOTFS1_PART_START + ROOTFS1_PART_SIZE))
	DATA_PART_START=$((ROOTFS2_PART_START + ROOTFS2_PART_SIZE))

	ROOTFS1_PART_END=$((ROOTFS2_PART_START - 1))
	ROOTFS2_PART_END=$((DATA_PART_START - 1))

	if [[ $ROOTFS1_PART_START == 0 ]] ; then
		ROOTFS1_PART_START=""
	fi

	(
	 echo n; echo p; echo 1; echo; echo +${BOOT_PART_SIZE_MB}M; \
	 echo n; echo p; echo $ROOTFSPART;  echo $ROOTFS1_PART_START; echo $ROOTFS1_PART_END; \
	 echo n; echo p; echo $ROOTFS2PART; echo $ROOTFS2_PART_START; echo $ROOTFS2_PART_END; \
	 echo n; echo p; echo $DATAPART;    echo $DATA_PART_START; echo; \
	 echo t; echo 1; echo c; echo a; echo 1; \
	 echo p; echo w;
	) | fdisk -u /dev/${EMMC_BLOCK} > /dev/null

	sync; sleep 1
	fdisk -u -l /dev/${EMMC_BLOCK}
}

format_emmc_parts()
{
	echo
	blue_underlined_bold_echo "Formatting partitions"

	mkfs.vfat -F 32 -n "boot" /dev/${EMMC_BLOCK}${PART}1

	if [[ $swupdate == 0 ]] ; then
		mkfs.ext4 /dev/${EMMC_BLOCK}${PART}${ROOTFSPART} -L rootfs
	elif [[ $swupdate == 1 ]] ; then
		mkfs.ext4 /dev/${EMMC_BLOCK}${PART}${ROOTFSPART}  -L rootfs1
		mkfs.ext4 /dev/${EMMC_BLOCK}${PART}${ROOTFS2PART} -L rootfs2
		mkfs.ext4 /dev/${EMMC_BLOCK}${PART}${DATAPART}    -L data
	fi

	sync; sleep 1
}

install_bootloader_to_emmc()
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	# Mount SD and eMMC boot partitions
	mkdir -p .emmc_boot
	mount /dev/${EMMC_BLOCK}${PART}1 .emmc_boot

	# Copy files to EMMC boot partition
	cp ${IMGS_PATH}/boot/* .emmc_boot/

	# Cleanup
	umount .emmc_boot
	rm -rf .emmc_boot
	sync
}

install_rootfs_to_emmc()
{
	echo
	blue_underlined_bold_echo "Installing rootfs"

	MOUNTDIR=/run/media/${EMMC_BLOCK}${PART}${ROOTFSPART}
	mkdir -p ${MOUNTDIR}
	mount /dev/${EMMC_BLOCK}${PART}${ROOTFSPART} ${MOUNTDIR}

	printf "Extracting files"
	tar --warning=no-timestamp -xpf ${IMGS_PATH}/${ROOTFS_IMAGE} -C ${MOUNTDIR} --checkpoint=.1200

	# Adjust u-boot-fw-utils for eMMC on the installed rootfs
	if [ -f "${MOUNTDIR}/etc/fw_env.config" ] && [ "$UPDATE_ENVTOOLS" = "yes" ]; then
		sed -i "s/\/dev\/mmcblk./\/dev\/${EMMC_BLOCK}/" ${MOUNTDIR}/etc/fw_env.config
	fi

	echo
	sync

	# copy debian images on the installed rootfs
	if [ "$DEBIAN_IMAGES_TO_ROOTFS_POINT" != "" ]; then
		mkdir -p ${MOUNTDIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/boot
		blue_underlined_bold_echo "Copying Debian images to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${IMGS_PATH}/${ROOTFS_IMAGE} ${MOUNTDIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/
		cp ${IMGS_PATH}/boot/* ${MOUNTDIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/boot/

		blue_underlined_bold_echo "Copying script to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		install -m 0755 ${G_META_VARISCITE_SDK_SRC_DIR}/scripts/variscite/am6_install_yocto.sh \
			${MOUNTDIR}/usr/sbin/install_debian.sh
		install -m 0755 ${G_META_VARISCITE_SDK_SRC_DIR}/scripts/variscite/echos.sh \
			${MOUNTDIR}/usr/sbin/
	fi

	umount ${MOUNTDIR}
}

stop_udev()
{
	if [ -f /lib/systemd/system/systemd-udevd.service ]; then
		systemctl -q stop \
			systemd-udevd-kernel.socket \
			systemd-udevd-control.socket \
			systemd-udevd
	fi
}

start_udev()
{
	if [ -f /lib/systemd/system/systemd-udevd.service ]; then
		systemctl -q start \
			systemd-udevd-kernel.socket \
			systemd-udevd-control.socket \
			systemd-udevd
	fi
}

usage()
{
	echo
	echo "This script installs Yocto on the SOM's internal storage device"
	echo
	echo " Usage: $(basename $0) <option>"
	echo
	echo " options:"
	echo " -h                           show help message"
	echo " -b                           only install the bootloader (U-Boot), and skip installing the rootfs"
	echo "                              Warning: the storage will be reformatted"
	echo " -u                           create two rootfs partitions (for swUpdate double-copy)."
	echo
}

finish()
{
	echo
	blue_bold_echo "${INSTALL_OS} installed successfully"
	if [[ "$0" = "$BASH_SOURCE" ]]; then
		exit 0
	fi
}

#################################################
#           Execution starts here               #
#################################################

if [[ $EUID != 0 ]] ; then
	red_bold_echo "This script must be run with super-user privileges"
	exit 1
fi

blue_underlined_bold_echo "*** Variscite AM6 Yocto eMMC Recovery ***"
echo

swupdate=0
bootloader_only=0

while getopts "bd:hu" OPTION;
do
	case $OPTION in
	h)
		usage
		exit 0
		;;
	u)
		swupdate=1
		;;
	b)
		bootloader_only=1
		;;
	*)
		usage
		exit 1
		;;
	esac
done

check_board

printf "Board: "
blue_bold_echo $BOARD

detect_OS

printf "OS to install: "
blue_bold_echo $INSTALL_OS

printf "Installing to internal storage device: "
blue_bold_echo eMMC

if [[ $swupdate == 1 ]] ; then
	blue_bold_echo "Creating two rootfs partitions"

	ROOTFS2PART=$((ROOTFSPART + 1))
	DATAPART=$((ROOTFS2PART + 1))
	DATA_SIZE=200
fi

check_images
stop_udev
delete_emmc
if [[ $swupdate == 0 ]] ; then
	create_emmc_parts
elif [[ $swupdate == 1 ]] ; then
	create_emmc_swupdate_parts
fi
format_emmc_parts
install_bootloader_to_emmc
if [[ $bootloader_only == 0 ]] ; then
	install_rootfs_to_emmc
fi
start_udev
finish
