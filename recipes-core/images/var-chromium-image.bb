DESCRIPTION = "Same image as var-default-image with Chromium browser added."
LICENSE = "MIT"

require recipes-core/images/var-default-image.bb

IMAGE_INSTALL:append = " chromium-ozone-wayland"

ROOTFS_POSTPROCESS_COMMAND:append = "install_chromium; "

install_chromium() {
    printf "\n[launcher]\nicon=/usr/share/icons/hicolor/24x24/apps/chromium.png\npath=/usr/bin/chromium-weston --enable-wayland-ime" >> ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini
}
