# rpi-yocto-build
build my own raspberry pi yocto

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
mkdir rpi-yocto-build && cd rpi-yocto-build
repo init -u git://github.com/pino-kim/rpi-yocto-build  -b master -m manifests/manifests.xml
repo sync
repo start work --all
```



