#!/bin/sh

if [ $# -lt 1 ]; then
	exit 0;
fi

get_current_root_device()
{
	for i in $(cat /proc/cmdline); do
		if [ "$(echo $i | cut -c1-5)" = "root=" ]; then
			CURRENT_ROOT="$(echo $i | cut -c6-)"
		fi
	done
}

get_update_part()
{
	CURRENT_PART="$(echo ${CURRENT_ROOT} | sed 's/.*p//')"

	if [ "${CURRENT_PART}" = "2" ]; then
		UPDATE_PART="3";
	else
		UPDATE_PART="2";
	fi
}

get_update_device()
{
	UPDATE_ROOT="${CURRENT_ROOT%?}${UPDATE_PART}"
}

format_update_device()
{
	umount $UPDATE_ROOT
	mkfs.ext4 $UPDATE_ROOT -F -L rootfs${UPDATE_PART} -q
}

if [ "$1" = "preinst" ]; then
	# get the current root device
	get_current_root_device

	# get the device to be updated
	get_update_part
	get_update_device

	# format the device to be updated
	format_update_device

	# create a symlink for the update process
	ln -sf $UPDATE_ROOT /dev/update
fi

if [ "$1" = "postinst" ]; then
	get_current_root_device

	# set TMPDIR to /tmp if it is not already set
	TMPDIR=${TMPDIR:=/tmp}

	# Create the mount point if it doesn't exist
	mkdir -p ${TMPDIR}/datadst

	# Adjust u-boot-fw-utils for eMMC on the installed rootfs
	mount -t ext4 /dev/update ${TMPDIR}/datadst
	CURRENT_BLK_DEV="${CURRENT_ROOT%p?}"
	sed -i "s/^#*\/dev\/mmcblk./$(echo ${CURRENT_BLK_DEV} | sed 's_/_\\/_g')/" ${TMPDIR}/datadst/etc/fw_env.config
	umount /dev/update

	get_update_part

	fw_setenv mmcpart $UPDATE_PART
fi
