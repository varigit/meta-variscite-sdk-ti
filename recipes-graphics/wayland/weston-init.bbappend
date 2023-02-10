FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://weston.ini \
"

RDEPENDS_${PN}_append = " adwaita-icon-theme adwaita-icon-theme-cursors"
