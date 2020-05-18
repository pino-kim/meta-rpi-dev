FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

#replace wireless-rgdb to wireless-regdb-static to fix #2
RDEPENDS_${PN}_remove = "wireless-regdb"
RDEPENDS_${PN}_append = " wireless-regdb-static"
