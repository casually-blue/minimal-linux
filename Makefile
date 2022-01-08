MAKEOPTS=-j8

run: root.img
	kvm -serial stdio -m 4096 -hda root.img -boot c

LINUX_MAJOR=5
LINUX_MINOR=15
LINUX_PATCH=7
LINUX_VERSION=${LINUX_MAJOR}.${LINUX_MINOR}.${LINUX_PATCH}

linux-src:
	wget https://mirrors.edge.kernel.org/pub/linux/kernel/v${LINUX_MAJOR}.x/linux-${LINUX_VERSION}.tar.gz
	tar -xf linux-${LINUX_VERSION}.tar.gz
	mv linux-${LINUX_VERSION} linux-src
	rm linux-${LINUX_VERSION}.tar.gz
	cd linux-src && make mrproper defconfig

clean:
	make -C init clean

.PHONY: init/init
init/init: init/init.c
	make -C init

linux-src/arch/x86/boot/bzImage:
	$(MAKE) $(MAKEOPTS) -C linux-src bzImage

kernel.gz: linux-src/arch/x86/boot/bzImage
	cp linux-src/arch/x86/boot/bzImage kernel.gz

mountroot:
	sudo losetup -Pf root.img
	mount mountpoints/root
	mount mountpoints/boot

unmountroot:
	umount mountpoints/boot
	umount mountpoints/root
	sudo losetup -d /dev/loop0

init-install: init/init
	mkdir -p mountpoints/root/sbin
	sudo cp init/init mountpoints/root/sbin/init

setup-grub: mountroot
	make grub-install

grub-install:
	sudo grub-install --target=i386-pc /dev/loop0 --boot-directory=mountpoints/boot/boot

grub-config:
	sudo cp grub/grub.cfg mountpoints/boot/boot/grub/grub.cfg

.PHONY: root.img
root.img: mountroot
	make grub-config
	make init-install 
	make unmountroot

