MAKEOPTS=-j8

all: minimal.iso

run: minimal.iso
	kvm -serial stdio -cdrom minimal.iso -m 4096

rootfs:
	mkdir rootfs

tmp: 
	mkdir tmp

linux-src:
	wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.15.7.tar.gz
	tar -xf linux-5.15.7.tar.gz
	mv linux-5.15.7 linux-src
	rm linux-5.15.7.tar.gz
	cd linux-src && make mrproper defconfig

clean:
	rm -rf tmp rootfs minimal.iso
	make -C init clean

rootfs/init: rootfs
	$(MAKE) $(MAKEOPTS) -C init 
	cp init/init rootfs

tmp/rootfs.gz: rootfs/init tmp
	cd rootfs && find . | cpio -R root:root -H newc -o | gzip > ../tmp/rootfs.gz

linux-src/arch/x86/boot/bzImage: linux-src
	$(MAKE) $(MAKEOPTS) -C linux-src bzImage

tmp/kernel.gz: linux-src/arch/x86/boot/bzImage tmp
	cp linux-src/arch/x86/boot/bzImage tmp/kernel.gz

.PHONY: syslinux
syslinux:
	cp syslinux/* tmp

minimal.iso: tmp/rootfs.gz tmp/kernel.gz syslinux
	xorriso \
		-as mkisofs \
		-o minimal.iso \
		-b isolinux.bin \
		-c boot.cat \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		./tmp

