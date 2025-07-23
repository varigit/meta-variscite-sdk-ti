DESCRIPTION = "Same image as var-default-image with Chromium browser added."
LICENSE = "MIT"


require recipes-core/images/var-default-image.bb

IMAGE_INSTALL:append = " chromium-ozone-wayland"
