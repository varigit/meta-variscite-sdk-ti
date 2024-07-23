SRC_URI:remove = "file://0001-psplash-Add-Arago-custom-color.patch"
SRC_URI:remove = "file://psplash-bar-img.h"

do_configure:remove() {
    install -m 0644 ${WORKDIR}/psplash-bar-img.h ${S}/
}
