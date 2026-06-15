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
EXTRA_IMAGE_FEATURES:append = " ssh-server-dropbear"
EXTRA_IMAGE_FEATURES:append = " package-management"
EXTRA_IMAGE_FEATURES:append = " allow-empty-password"
EXTRA_IMAGE_FEATURES:append = " empty-root-password"
EXTRA_IMAGE_FEATURES:append = " allow-root-login"
EXTRA_IMAGE_FEATURES:append = " serial-autologin-root"

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

# Prevent sysvinit from being automatically added through DISTRO_FEATURES_OPTED_OUT.
DISTRO_FEATURES_OPTED_OUT:append = " sysvinit"

HOSTTOOLS_NONFATAL:append = " ssh"

# Raspberry Pi image outputs.
IMAGE_FSTYPES:append:${MACHINE} = " rpi-sdimg ext4"

# Raspberry Pi board options.
ENABLE_UART = "1"
ENABLE_I2C = "1"
ENABLE_SPI_BUS = "1"

# Keep default Raspberry Pi boot flow for real board validation.
# If your project explicitly requires U-Boot, set this to "1".
# For pure Raspberry Pi firmware boot, keep it disabled.
RPI_USE_U_BOOT = "0"

GPU_FREQ = "250"

# Rootfs size.
# For real board validation, use a practical size rather than tiny QEMU-only size.
# 1048576 KiB = 1 GiB
# 2097152 KiB = 2 GiB
# 8388608 KiB = 8 GiB
IMAGE_ROOTFS_SIZE:forcevariable = "1048576"
IMAGE_OVERHEAD_FACTOR:forcevariable = "1.0"
IMAGE_ROOTFS_EXTRA_SPACE:forcevariable = "0"

# NOTE:
# QB_* variables are for runqemu.
# This project currently uses qemu-system-aarch64 directly for smoke testing,
# so QB_* settings are intentionally omitted.
EOF

echo "Done."
echo "You are now in: $(pwd)"
echo "MACHINE=${MACHINE}"
echo "Build dir=${DIR}"
echo "Next:"
echo "  bitbake ${BITBAKEIMAGE}"
