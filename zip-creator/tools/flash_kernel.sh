#!/sbin/sh
cd /tmp/
./busybox dd if=/dev/mtd/mtd0 of=./boot.img bs=5242880 count=1
./unpackbootimg -i /tmp/boot.img
./mkbootimg \
	--kernel /tmp/zImage \
	--ramdisk /tmp/boot.img-ramdisk.gz \
	--pagesize 4096 \
	--base 0x0 \
	--kernel_offset 0x208000 \
	--ramdisk_offset 0x1300000 \
	--second_offset 0x1100000 \
	--tags_offset 0x200100 \
	--cmdline "console=ttyDCC0 androidboot.hardware=huawei" \
	--output /tmp/newboot.img
