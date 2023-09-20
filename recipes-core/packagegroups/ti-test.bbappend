RDEPENDS_${PN} += "\
    evtest \
    expect \
    minicom \
    powervr-graphics \
    screen \
    spidev-test \
    var-mii \
    wget \
"

# to save about 213 MB required by ltp-ddt package (without considering its dependencies)
RDEPENDS_${PN}:remove = "\
    ltp-ddt \
"

# to get utility dependencies introduced by ltp-ddt
RDEPENDS_${PN} += "\
    acl \
    at \
    pm-qa \
    serialcheck \
    memtester \
"

# to get utility dependencies introduced by ltp (included in ltp-ddt)
RDEPENDS_${PN} += "\
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
