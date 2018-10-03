# rpi3-arm64-distro
build my own raspberry pi3 arm64 yocto distro

## Dependencies

This distro dependends on : 

* URI: git://git.yoctoproject.org/poky
	* branch: master
	* revision: HEAD
* URI: git://git.openembedded.org/meta-openembedded
	* layers: meta-oe, meta-multimedia, meta-networking, meta-python
	* branch: master
	* revision: HEAD
* URI: git://git.yoctoproject.org/meta-raspberrypi
	* branch: master
	* revision: HEAD

## Create workspace
```text
mkdir rpi3-arm64-distro && cd rpi3-arm64-distro
repo init -u git://github.com/pino-kim/rpi3-arm64-distro  -b master -m manifests/manifests.xml
repo sync
repo start work --all
```



