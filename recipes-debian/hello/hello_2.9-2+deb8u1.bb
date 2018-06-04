inherit debian-dsc

# TODO: automatically get URI through the apt repository DB?
# or, is debian-dsc.class is intended to be merged into OE-Core?
DSC_URI = "http://ftp.de.debian.org/debian/pool/main/h/${PN}/${PN}_${PV}.dsc;md5sum=faa827e0ff1d7e76c12488ed77e8fc76"

# TODO: add inherit common functions to fetch other source files and build them
