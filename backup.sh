#!/system/bin/sh

mkdir -p /sdcard/unbrick

# Back up
busybox dd if=/dev/block/mmcblk0 of=/sdcard/unbrick/unbrick.img
busybox dd if=/dev/block/mmcblk0p1 of=/sdcard/unbrick/sdm_hdr.mbn
busybox dd if=/dev/block/mmcblk0p2 of=/sdcard/unbrick/sbl1.mbn
busybox dd if=/dev/block/mmcblk0p3 of=/sdcard/unbrick/sbl2.mbn
busybox dd if=/dev/block/mmcblk0p4 of=/sdcard/unbrick/sbl3.mbn
busybox dd if=/dev/block/mmcblk0p5 of=/sdcard/unbrick/aboot.mbn
busybox dd if=/dev/block/mmcblk0p6 of=/sdcard/unbrick/rpm.mbn
busybox dd if=/dev/block/mmcblk0p8 of=/sdcard/unbrick/tz.mbn

# Make partition tables
busybox dd if=/dev/block/mmcblk0p9 of=/sdcard/unbrick/pitfile.pit
fdisk -l > /sdcard/unbrick/fdisk.txt
fdisk -l /dev/block/mmcblk0 > /sdcard/unbrick/fdisk-mmc.txt

# Compress and clean up
busybox gzip /sdcard/unbrick/*
mv /sdcard/unbrick/*.gz /sdcard/unbrick.gz
rm -fR /sdcard/unbrick
chmod 0777 /sdcard/unbrick.gz

exit 0
