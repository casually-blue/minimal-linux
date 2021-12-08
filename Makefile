rootfs/init:
	gcc -static init/init.c -o rootfs/init

tmp/rootfs.gz: rootfs/init
	cd rootfs && find . | cpio -R root:root -H newc -o | gzip > ../tmp/rootfs.gz

tmp/kernel.gz:
	cp linux-src/arch/x86/boot/bzImage tmp/kernel.gz

minimal.iso: tmp/rootfs.gz tmp/kernel.gz
	cp syslinux/* tmp
	xorriso \
		-as mkisofs \
		-o minimal.iso \
		-b isolinux.bin \
		-c boot.cat \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		./tmp

run: minimal.iso
	kvm -serial stdio -cdrom minimal.iso -m 4096


