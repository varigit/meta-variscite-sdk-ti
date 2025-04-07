# Copyright (C) 2017 Variscite Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Variscite Image to validate i.MX machines. \
This image contains everything used to test i.MX machines including GUI, \
demos and lots of applications. This creates a very large image, not \
suitable for production."
LICENSE = "MIT"

SWUPDATE_BASE_IMAGE ??= "${@bb.utils.contains('DISTRO', 'b2qt', 'recipes-qt/images/b2qt-embedded-qt6-image.bb', 'recipes-core/images/var-default-image.bb', d)}"
require ${SWUPDATE_BASE_IMAGE}

### WARNING: This image is NOT suitable for production use and is intended
###          to provide a way for users to reproduce the image used during
###          the validation process of i.MX BSP releases.

CORE_IMAGE_EXTRA_INSTALL += " \
	swupdate \
	swupdate-www \
	kernel-image \
	kernel-devicetree \
"

QBSP_IMAGE_CONTENT = ""

# Due to the SWUpdate image will not fit the default NAND size.
# Removing default ubi creation for this image
IMAGE_FSTYPES:remove = "multiubi"
