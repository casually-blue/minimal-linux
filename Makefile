MAKEOPTS=-j8

all: minimal.iso

run: minimal.iso
	kvm -serial stdio -cdrom minimal.iso -m 4096

rootfs:
	mkdir rootfs

isodir: 
	mkdir isodir

linux-src:
	wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.15.7.tar.gz
	tar -xf linux-5.15.7.tar.gz
	mv linux-5.15.7 linux-src
	rm linux-5.15.7.tar.gz
	cd linux-src && make mrproper defconfig

clean:
	rm -rf isodir rootfs/init minimal.iso
	make -C init clean

.PHONY=rootfs/init
rootfs/init: rootfs
	$(MAKE) $(MAKEOPTS) -C init 
	cp init/init rootfs

isodir/rootfs.gz: rootfs/init isodir
	cd rootfs && find . | cpio -R root:root -H newc -o | gzip > ../isodir/rootfs.gz

linux-src/arch/x86/boot/bzImage: linux-src
	$(MAKE) $(MAKEOPTS) -C linux-src bzImage

isodir/kernel.gz: linux-src/arch/x86/boot/bzImage isodir
	cp linux-src/arch/x86/boot/bzImage isodir/kernel.gz

SYSLINUX_FILES=$(wildcard syslinux/*)
TMP_SYS=$(patsubst syslinux/%,isodir/%,$(SYSLINUX_FILES))

isodir/%: syslinux/%
	cp $^ $@

minimal.iso: isodir/rootfs.gz isodir/kernel.gz $(TMP_SYS)
	xorriso \
		-as mkisofs \
		-o minimal.iso \
		-b isolinux.bin \
		-c boot.cat \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		./isodir

