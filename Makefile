MAKEOPTS=-j8

run: minimal.iso
	kvm -serial stdio -cdrom minimal.iso -m 4096

rootfs/init:
	$(MAKE) $(MAKEOPTS) -C init
	cp init/init rootfs

tmp/rootfs.gz: rootfs/init
	cd rootfs && find . | cpio -R root:root -H newc -o | gzip > ../tmp/rootfs.gz

linux-src/arch/x86/boot/bzImage:
	$(MAKE) $(MAKEOPTS) -C linux-src bzImage

tmp/kernel.gz: linux-src/arch/x86/boot/bzImage
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

