RDEPENDS:${PN} += "\
    evtest \
    expect \
    minicom \
    powervr-graphics \
    screen \
    spidev-test \
    wget \
"

RDEPENDS:${PN}:remove:am335x-var-som = "\
    powervr-graphics \
"

# to save about 213 MB required by ltp-ddt package (without considering its dependencies)
RDEPENDS:${PN}:remove = "\
    ltp-ddt \
"

# to get utility dependencies introduced by ltp-ddt
RDEPENDS:${PN} += "\
    acl \
    at \
    pm-qa \
    serialcheck \
    memtester \
"

# to get utility dependencies introduced by ltp (included in ltp-ddt)
RDEPENDS:${PN} += "\
    attr \
    bash \
    bc \
    coreutils \
    cpio \
    cronie \
    curl \
    e2fsprogs \
    e2fsprogs-mke2fs \
    expect \
    file \
    gawk \
    gdb \
    gzip \
    iproute2 \
    ldd \
    libaio \
    logrotate \
    net-tools \
    perl \
    python3-core \
    procps \
    quota \
    unzip \
    util-linux \
    which \
    tar \
"

# to add Cortex-M binaries in the image
RDEPENDS:${PN}:append:am62x-var-som = " ti-mcu-plus-sdk"
# to add Cortex-R5F binaries in the image
RDEPENDS:${PN}:append:am62px-var-som = " ti-mcu-plus-sdk"

TI_TEST_TI_TOOLS:remove:k3 = "ti-rtos-firmware"

# piglit takes ~2GB of space
TI_TEST_EXTRAS:remove = "piglit"
