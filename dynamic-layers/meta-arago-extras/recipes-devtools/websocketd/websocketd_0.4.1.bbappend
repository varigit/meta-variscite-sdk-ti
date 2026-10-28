# Upstream renamed master to main; keep the existing pinned revision.
SRC_URI:remove = "git://${GO_IMPORT}.git;protocol=https;branch=master;destsuffix=src/${GO_IMPORT}"
SRC_URI:append = " git://${GO_IMPORT}.git;protocol=https;branch=main;destsuffix=src/${GO_IMPORT}"
