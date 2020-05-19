#!/bin/bash
# Bootstrapper for buildbot slave

DIR="build"
MACHINE="raspberrypi3-64"
CONFFILE="conf/auto.conf"
BITBAKEIMAGE="core-image-minimal"

# clean up the output dir
#echo "Cleaning build dir"
#rm -rf $DIR

# make sure sstate is there
#echo "Creating sstate directory"
#mkdir -p ~/sstate/$MACHINE

# fix permissions set by buildbot
#echo "Fixing permissions for buildbot"
#umask -S u=rwx,g=rx,o=rx
#chmod -R 755 .

# Reconfigure dash on debian-like systems
which aptitude > /dev/null 2>&1
ret=$?
if [ "$(readlink /bin/sh)" = "dash" -a "$ret" = "0" ]; then
	sudo aptitude install expect -y
	expect -c 'spawn sudo dpkg-reconfigure -freadline dash; send "n\n"; interact;'
elif [ "${0##*/}" = "dash" ]; then
	echo "dash as default shell is not supported"
	return
fi

# bootstrap OE
echo "Init OE"
export BASH_SOURCE="openembedded-core/oe-init-build-env"
. ./openembedded-core/oe-init-build-env $DIR

# add the missing layers
echo "Adding layers"
bitbake-layers add-layer ../openembedded-core/meta
bitbake-layers add-layer ../meta-openembedded/meta-oe
bitbake-layers add-layer ../meta-openembedded/meta-python
bitbake-layers add-layer ../meta-openembedded/meta-multimedia
bitbake-layers add-layer ../meta-openembedded/meta-networking/
bitbake-layers add-layer ../meta-raspberrypi/
bitbake-layers add-layer ../meta-rpi-dev


# fix the configuration
echo "Creating auto.conf"

if [ -e $CONFFILE ]; then
	    rm -rf $CONFFILE
    fi
    cat <<EOF > $CONFFILE
MACHINE ?= "${MACHINE}" 

# rootfs for debugging
#IMAGE_GEN_DEBUGFS = "1"
#IMAGE_FSTYPES_DEBUGFS = "tar.gz"

EXTRA_IMAGE_FEATURES ?= "debug-tweaks"
EXTRA_IMAGE_FEATURES_append = " ssh-server-dropbear"
EXTRA_IMAGE_FEATURES_append = " package-management"

PACKAGECONFIG_append_pn-qemu-native = " sdl"
PACKAGECONFIG_append_pn-nativesdk-qemu = " sdl"

USER_CLASSES ?= "buildstats buildhistory buildstats-summary image-mklibs image-prelink"

require conf/distro/include/no-static-libs.inc
require conf/distro/include/yocto-uninative.inc
require conf/distro/include/security_flags.inc

INHERIT += "uninative"

#  DISTRO_FEATURES append set 
DISTRO_FEATURES_append = " largefile opengl ptest multiarch wayland pam  systemd "

# Using systemd instead of SysVinit
VIRTUAL-RUNTIME_init_manager = "systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"

HOSTTOOLS_NONFATAL_append = " ssh"

# Add Rpi board configuration
# Read this doc carefully : https://meta-raspberrypi.readthedocs.io/en/latest/extra-build-config.html
IMAGE_FSTYPES_append = " rpi-sdimg"
ENABLE_UART = "1" 
RPI_USE_U_BOOT = "1" 
ENABLE_I2C = "1" 
ENABLE_SPI_BUS = "1" 

# FiX uart output cracked #3
GPU_FREQ = "250"
EOF

