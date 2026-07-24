# avoid commercial license requirements
GSTREAMER_DEPS:remove:arago = "${@bb.utils.contains('LICENSE_FLAGS_ACCEPTED', 'commercial', '', 'gstreamer1.0-libav-dev', d)}"
