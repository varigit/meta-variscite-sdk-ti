
# Replace currently disallowed rev=<tag> in SRC_URI with git sha1s
python() {
    src_uri = d.getVar('SRC_URI')
    # googletest
    src_uri = src_uri.replace("release-1.8.0", "ec44c6c1675c25b9827aacd08c02433cccde7780")
    # flatbuffers
    src_uri = src_uri.replace("v1.11.0", "9e7e8cbe9f675123dd41b7c62868acad39188cae")
    d.setVar('SRC_URI', src_uri)
}
