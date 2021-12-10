MAKEOPTS=-j8

all: minimal.iso

run: minimal.iso
	kvm -serial stdio -cdrom minimal.iso -m 4096

rootfs:
	mkdir rootfs

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
	rm -rf isodir rootfs/init minimal.iso
	make -C init clean

ROOTFS_FILES=$(shell find rootfs)

init/init:
	make -C init

rootfs/sbin:
	mkdir -p rootfs/sbin

rootfs/sbin/init: rootfs/sbin init/init.c
	$(MAKE) $(MAKEOPTS) -C init 
	cp init/init rootfs/sbin

isodir/rootfs.gz: rootfs/sbin/init isodir $(ROOTFS_FILES)
	cd rootfs && find . | cpio -R root:root -H newc -o | gzip > ../isodir/rootfs.gz

linux-src/arch/x86/boot/bzImage:
	$(MAKE) $(MAKEOPTS) -C linux-src bzImage

isodir/kernel.gz: linux-src/arch/x86/boot/bzImage isodir
	cp linux-src/arch/x86/boot/bzImage isodir/kernel.gz

GRUB_FILES=$(shell find grub)
ISO_GRUB_FILES=$(patsubst %,isodir/boot/%, $(GRUB_FILES))

isodir/boot:
	mkdir -p isodir/boot

isodir/boot/%: % isodir/boot
	cp -ar $< $@



minimal.iso: isodir/rootfs.gz isodir/kernel.gz $(ISO_GRUB_FILES)
	rm -f minimal.iso
	grub-mkrescue -o minimal.iso isodir

