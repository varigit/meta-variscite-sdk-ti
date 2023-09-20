DESCRIPTION = "Variscite Thin Image based on var-default-image. \
This create quite a small image, suitable for NAND installation."
LICENSE = "MIT"

require var-default-image.bb

IMAGE_INSTALL:remove += "\
    ltp-ddt \
    packagegroup-arago-tisdk-multimedia \
    packagegroup-arago-tisdk-qte \
"

# to get GStreamer dependencies introduced by packagegroup-arago-tisdk-multimedia
# packagegroup-arago-gst could be added bbut this will introduce some qt5 packages.
# To further strip the image, qt5 packageconfig could be commented out in
# meta-arago-extras/recipes-multimedia/gstreamer/gstreamer1.0-plugins-good_1.16.%.bbappend
#IMAGE_INSTALL += "\
#    packagegroup-arago-gst \
#"
