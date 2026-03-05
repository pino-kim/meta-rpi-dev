#!/bin/bash
# Yocto/OE setup script (source this file)
# Usage:
#   . ./meta-rpi-dev/setup.sh
#   . ./meta-rpi-dev/setup.sh raspberrypi4-64 build-rpi4 core-image-weston

# ---------- config (can be overridden by args) ----------
DIR="${2:-build}"
MACHINE="${1:-raspberrypi3-64}"
BITBAKEIMAGE="${3:-core-image-minimal}"
CONFFILE="conf/auto.conf"

# ---------- safety: must be sourced ----------
# If executed, exit; if sourced, return works.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo "ERROR: This script must be sourced:"
    echo "  . ${BASH_SOURCE[0]}"
    exit 1
fi

# ---------- do NOT touch /bin/sh or interactive tty ----------
# Old dash/expect block removed on purpose:
# - It can mess up byobu/tmux PTY
# - Build scripts should not reconfigure system shell

echo "Init OE (DIR=${DIR}, MACHINE=${MACHINE})"
. ./openembedded-core/oe-init-build-env "${DIR}"

# Now we are inside ${DIR}
echo "Adding layers"
bitbake-layers add-layer ../openembedded-core/meta >/dev/null 2>&1 || true
bitbake-layers add-layer ../meta-openembedded/meta-oe >/dev/null 2>&1 || true
bitbake-layers add-layer ../meta-openembedded/meta-python >/dev/null 2>&1 || true
bitbake-layers add-layer ../meta-openembedded/meta-multimedia >/dev/null 2>&1 || true
bitbake-layers add-layer ../meta-openembedded/meta-networking >/dev/null 2>&1 || true
bitbake-layers add-layer ../meta-raspberrypi >/dev/null 2>&1 || true
bitbake-layers add-layer ../meta-rpi-dev >/dev/null 2>&1 || true

echo "Creating auto.conf (${CONFFILE})"
rm -f "${CONFFILE}"

cat <<EOF > "${CONFFILE}"
# Auto-generated
MACHINE ?= "${MACHINE}"

# Debugging convenience
#EXTRA_IMAGE_FEATURES ?= "debug-tweaks"
EXTRA_IMAGE_FEATURES:append = " ssh-server-dropbear"
EXTRA_IMAGE_FEATURES:append = " package-management"

# QEMU UI (optional)
PACKAGECONFIG:append:pn-qemu-native = " sdl"
PACKAGECONFIG:append:pn-nativesdk-qemu = " sdl"

# Keep INHERIT minimal.
# NOTE: image-mklibs / image-prelink are not present in newer OE-Core -> do NOT add them.
INHERIT:append = " buildstats buildhistory buildstats-summary uninative"

# Avoid duplicate requires: defaultsetup.conf already includes these on newer series.
# require conf/distro/include/no-static-libs.inc
# require conf/distro/include/yocto-uninative.inc
# require conf/distro/include/security_flags.inc

# systemd
DISTRO_FEATURES:append = " largefile opengl ptest multiarch wayland pam systemd"
VIRTUAL-RUNTIME_init_manager = "systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED:append = " sysvinit"

HOSTTOOLS_NONFATAL:append = " ssh"

# Raspberry Pi extras (meta-raspberrypi)
IMAGE_FSTYPES:append:raspberrypi3-64 = " rpi-sdimg"
IMAGE_FSTYPES:append:raspberrypi4-64 = " rpi-sdimg"
IMAGE_FSTYPES:append:raspberrypi5 = " rpi-sdimg"
ENABLE_UART = "1"
RPI_USE_U_BOOT = "1"
ENABLE_I2C = "1"
ENABLE_SPI_BUS = "1"

GPU_FREQ = "250"
EOF

echo "Done."
echo "You are now in: $(pwd)"
echo "Next:"
echo "  bitbake ${BITBAKEIMAGE}"
