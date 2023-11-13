FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://weston.ini \
"

RDEPENDS_${PN}:append = " adwaita-icon-theme adwaita-icon-theme-cursors"
