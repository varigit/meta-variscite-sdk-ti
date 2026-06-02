FILESEXTRAPATHS:prepend := "${THISDIR}/chromium-ozone-wayland:"

SRC_URI:append = " \
    file://chromium-weston \
"

do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/chromium-weston ${D}${bindir}/chromium-weston
}

FILES:${PN}:append = " \
    ${bindir}/chromium-weston \
"
