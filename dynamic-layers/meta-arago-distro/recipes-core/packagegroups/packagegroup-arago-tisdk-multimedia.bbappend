# ffmpeg and mpv have commercial licenses. Don't include them unless these licenses are acceptable
MULTIMEDIA:remove = "${@bb.utils.contains('LICENSE_FLAGS_ACCEPTED', 'commercial', '', 'ffmpeg mpv', d)}"
