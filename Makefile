MAKEOPTS=-j8

all: minimal.iso

run: minimal.iso
	kvm -serial stdio -cdrom minimal.iso -m 4096 -hda root.img -boot d

isodir: 
	mkdir isodir

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
	rm -rf isodir minimal.iso
	make -C init clean

.PHONY: init/init
init/init:
	make -C init

.PHONY: root/sbin/init
root/sbin/init: init/init
	mount root || /bin/true
	$(MAKE) $(MAKEOPTS) -C init 
	cp init/init root/sbin
	umount root

linux-src/arch/x86/boot/bzImage:
	$(MAKE) $(MAKEOPTS) -C linux-src bzImage

isodir/kernel.gz: linux-src/arch/x86/boot/bzImage isodir
	cp linux-src/arch/x86/boot/bzImage isodir/kernel.gz

isodir/boot/grub/grub.cfg:
	mkdir -p isodir/boot/grub
	cp grub/grub.cfg isodir/boot/grub/grub.cfg

minimal.iso: isodir/kernel.gz isodir/boot/grub/grub.cfg root/sbin/init
	rm -f minimal.iso
	grub-mkrescue -o minimal.iso isodir

