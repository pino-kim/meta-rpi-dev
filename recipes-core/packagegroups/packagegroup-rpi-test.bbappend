FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

#replace wireless-rgdb to wireless-regdb-static to fix #2
RDEPENDS_${PN}:remove = "wireless-regdb"
RDEPENDS_${PN}:append = " wireless-regdb-static"
