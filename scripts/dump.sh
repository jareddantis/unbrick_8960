#!/system/bin/sh

mkdir -p /sdcard/unbrick
dd if=/dev/block/mmcblk0p1 of=/sdcard/unbrick/sdm_hdr.mbn
dd if=/dev/block/mmcblk0p2 of=/sdcard/unbrick/sbl1.mbn
dd if=/dev/block/mmcblk0p3 of=/sdcard/unbrick/sbl2.mbn
dd if=/dev/block/mmcblk0p4 of=/sdcard/unbrick/sbl3.mbn
dd if=/dev/block/mmcblk0p5 of=/sdcard/unbrick/aboot.mbn
dd if=/dev/block/mmcblk0p6 of=/sdcard/unbrick/rpm.mbn
dd if=/dev/block/mmcblk0p8 of=/sdcard/unbrick/tz.mbn
dd if=/dev/block/mmcblk0p9 of=/sdcard/unbrick/pitfile.pit

exit 0