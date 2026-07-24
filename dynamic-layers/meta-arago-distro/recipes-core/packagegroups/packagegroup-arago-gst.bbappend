# libav has a commercial license. Don't include it as a gstreamer plugin unless this license is acceptable
GSTREAMER_DEPS:remove = "${@bb.utils.contains('LICENSE_FLAGS_ACCEPTED', 'commercial', '', 'gstreamer1.0-libav', d)}"
