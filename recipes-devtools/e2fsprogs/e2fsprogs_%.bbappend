do_install:append:class-native() {
	MKE2FS_NO_64="${@d.getVar('MKE2FS_NO_64', True) or ''}"

	if [ -n "$MKE2FS_NO_64" ]; then
		sed -i 's/,64bit//g' "${D}${sysconfdir}/mke2fs.conf"
		echo "MKE2FS_NO_64.5 ${MKE2FS_NO_64}" > /tmp/mkfs
    fi
}
