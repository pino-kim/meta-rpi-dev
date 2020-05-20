# meta-rpi-dev
build your own raspberry pi image by yocto build system.

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/pino-kim/meta-rpi-dev/blob/master/LICENSE)

## Target board
* raspberrypi 3b
* raspberrypi 4b (not yet tested)

## Dependencies

This distro dependends on : 

* URI: git://github.com/openembedded/openembedded-core
	* branch: master
	* revision: HEAD
* URI: git://github.com/openembedded/meta-openembedded
	* layers: meta-oe, meta-multimedia, meta-networking, meta-python
	* branch: master
	* revision: HEAD
* URI: git://github.com/openembedded/bitbake
	* branch: master
	* revision: HEAD
* URI: git://github.com/agherzan/meta-raspberrypi
	* branch: master
	* revision: HEAD

## Quick Start

Note: You only need this if you do not have an existing Yocto Project build environment.

```text
sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
     xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
     pylint3 xterm
```

You can find more information below site to set Yocto Project build environment.

Yocto Project Quick Build : [Build Host Packages](https://www.yoctoproject.org/docs/latest/brief-yoctoprojectqs/brief-yoctoprojectqs.html#brief-build-system-packages)

Make sure to [install the `repo` command by Google](https://source.android.com/setup/downloading#installing-repo) first. 

## Create workspace
```text
mkdir rpi-yocto-build && cd rpi-yocto-build
repo init -u git://github.com/pino-kim/meta-rpi-dev  -b master -m manifests/manifests.xml
repo sync
repo start work --all
```
## Update existing workspace
In order to bring all the layers up to date with upstream
```text
cd rpi-yocto-build
repo sync
repo rebase
```

## Setup Build Environment
```text
. ./meta-rpi-dev/setup.sh
```

## Support Machine
* raspberrypi3
* raspberrypi3-64 (64 bit kernel & userspace)
* raspberrypi4
* raspberrypi4-64 (64 bit kernel & userspace)

## Build Image
```text
MACHINE=raspberrypi3-64 bitbake rpi-test-image
```
## flash image
After build succes, you can find sdimg in deploy

Recomend you to flash sdcard by [Etcher](https://www.balena.io/etcher/)

## Maintainer
sungwon.pino at gmail.com


