FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://0001-ti-apps-launcher-add-am62x-var-som-profile.patch \
    file://0003-ti-apps-launcher-deviceinfo-ui.patch \
    file://0004-ti-apps-launcher-improve-topbar-close-button.patch \
    file://0005-ti-apps-launcher-use-variscite-logo.patch \
    file://0006-ti-apps-launcher-use-variscite-support-url.patch \
    file://0007-ti-apps-launcher-check-chromium-runtime-dependency.patch \
    file://0008-ti-apps-launcher-create-profile-for-VAR-SOM-AM62P.patch \
    file://0009-arm_analytics-whitelist-AM62PX_VAR_SOM-to-use-HW-acc.patch \
    file://TI-logo-24x24.png \
    file://ti-apps-launcher-weston \
    file://Variscite_Logo_White.png \
"

APPS_DEFINES:am62x-var-som = "SOC_AM62"
APPS_DEFINES:am62px-var-som = "SOC_AM62P"

do_configure:prepend() {
    install -d ${S}/images
    install -m 0644 ${WORKDIR}/Variscite_Logo_White.png ${S}/images/Variscite_Logo_White.png
}

RDEPENDS:${PN}:remove = " \
    pulseaudio-service \
"

SYSTEMD_AUTO_ENABLE:${PN} = "disable"

do_install:append() {
    install -d ${D}/usr/share/weston
    install -m 0644 ${WORKDIR}/TI-logo-24x24.png ${D}/usr/share/weston/TI-logo-24x24.png
    install -m 0755 ${WORKDIR}/ti-apps-launcher-weston ${D}${bindir}/ti-apps-launcher-weston
}

FILES:${PN}:append = " \
    ${bindir}/ti-apps-launcher-weston \
    ${datadir}/weston/TI-logo-24x24.png \
"
