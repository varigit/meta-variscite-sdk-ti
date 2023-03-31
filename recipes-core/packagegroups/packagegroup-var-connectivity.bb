DESCRIPTION = "Derived from packagegroup-arago-tisdk-connectivity"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

# WLAN support packages.
# These are the packages that all platforms use for WLAN support
# add wireless-regdb-static
WLAN_COMMON = "\
    iw \
    softap-udhcpd-config \
    eventdump \
    wlconf \
    wireless-regdb-static \
"

WLAN_TI = "\
    wpa-supplicant \
    hostapd \
"

BT_COMMON = "\
    bluez5 \
    bluez5-obex \
    bluez5-noinst-tools \
    bluez5-testtools \
    sbc \
"

CONNECTIVITY_RDEPENDS = " \
    htop \
    iptables \
    iproute2 \
    iproute2-tc \
    iproute2-devlink \
    net-snmp \
    net-snmp-server-snmpd \
    ${WLAN_COMMON} \
    ${WLAN_TI} \
    ${BT_COMMON} \
"

RDEPENDS_${PN} = "\
    ${CONNECTIVITY_RDEPENDS} \
"
