# break dependency on base package for -dev package
# otherwise SDK fails to build as the main openssh and dropbear packages
# conflict with each other
RDEPENDS:${PN}-dev = ""
