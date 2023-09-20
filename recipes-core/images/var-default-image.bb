DESCRIPTION = "Variscite Image based on tisdk-default-image to validate AM6 \
machines tisdk-default-image. This image contains everything used to test AM6 \
machines including GUI, demos and lots of applications. This creates a very \
large image, not suitable for production."
LICENSE = "MIT"

inherit core-image

### WARNING: This image is NOT suitable for production use and is intended
###          to provide a way for users to reproduce the image used during
###          the validation process of Varsicite BSP releases

IMAGE_FEATURES += " \
    splash \
    package-management \
    ssh-server-dropbear \
    hwcodecs \
    debug-tweaks \
    nfs-server \
    tools-debug \
"

QT5_PKGS = "${@oe.utils.conditional('QT_PROVIDER', 'qt5', 'packagegroup-arago-tisdk-qte', '', d)}"

DOCKER_PKGS	= "${@bb.utils.contains('DISTRO_FEATURES', 'virtualization', 'docker-ce python3-docker-compose', '', d)}"

OPENCL = " \
    ${@bb.utils.contains('MACHINE_FEATURES','dsp','ti-opencl','',d)} \
    ${@bb.utils.contains('MACHINE_FEATURES','dsp','packagegroup-arago-tisdk-opencl-extra','',d)} \
"

SWUPDATE_PKGS = " \
	swupdate \
	swupdate-www \
	kernel-image \
	kernel-devicetree \
"

IMAGE_INSTALL += "\
    packagegroup-arago-base \
    packagegroup-arago-console \
    packagegroup-arago-base-tisdk \
    ltp-ddt \
    ti-test \
    ${@['','packagegroup-arago-tisdk-opencl'][oe.utils.all_distro_features(d, 'opencl', True, False) and bb.utils.contains('MACHINE_FEATURES', 'dsp', True, False, d)]} \
    packagegroup-var-connectivity \
    packagegroup-arago-tisdk-crypto \
    packagegroup-arago-tisdk-multimedia \
    packagegroup-arago-tisdk-amsdk \
    packagegroup-arago-tisdk-addons \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', "weston-init weston-examples", '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-analyze', '', d)} \
    zstd \
    ${@oe.utils.all_distro_features(d, "opencl", "${OPENCL}")} \
    packagegroup-dl \
    libcamera \
    resize-rootfs \
    ${DOCKER_PKGS} \
    ${QT5_PKGS} \
    ${@bb.utils.contains("BBFILE_COLLECTIONS","swupdate", "${SWUPDATE_PKGS}",'',d)} \
"

WIC_CREATE_EXTRA_ARGS += " --no-fstab-update"

systemd_disable_vt () {
    rm ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/getty.target.wants/getty@tty*.service
}

IMAGE_PREPROCESS_COMMAND:append = " ${@ 'systemd_disable_vt;' if bb.utils.contains('DISTRO_FEATURES', 'systemd', True, False, d) and bb.utils.contains('USE_VT', '0', True, False, d) else ''} "
