@echo off
echo "Please install Python2.7 before running this tool
echo "Root/Rooted device required"
mkdir backup
cd backup
echo "Pulling partition Table, creating partition0.bin"
c:\Python27\python ..\getpartbin.py
echo "Pulling Bootloaders"
adb shell su -c 'dd if=/dev/block/mmcblk0p1 of=/sdcard/smd_hdr.mbn'  
adb pull /sdcard/smd_hdr.mbn
adb shell su -c 'dd if=/dev/block/mmcblk0p2 of=/sdcard/sbl1.mbn  '
adb pull /sdcard/sbl1.mbn
adb shell su -c 'dd if=/dev/block/mmcblk0p3 of=/sdcard/sbl2.mbn  '
adb pull /sdcard/sbl2.mbn
adb shell su -c 'dd if=/dev/block/mmcblk0p5 of=/sdcard/rpm.mbn  '
adb pull /sdcard/rpm.mbn
adb shell su -c 'dd if=/dev/block/mmcblk0p6 of=/sdcard/sbl3.mbn'
adb pull /sdcard/sbl3.mbn
adb shell su -c 'dd if=/dev/block/mmcblk0p7 of=/sdcard/aboot.mbn'
adb pull /sdcard/aboot.mbn
adb shell su -c 'dd if=/dev/block/mmcblk0p9 of=/sdcard/tz.mbn'
adb pull /sdcard/tz.mbn
adb shell su -c 'dd if=/dev/block/mmcblk0p11 of=/sdcard/pitfile.pit'
adb pull /sdcard/pitfile.pit
cd ..
 
