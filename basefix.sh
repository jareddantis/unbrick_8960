# SHV-E160L 'baseband unknown' repair file
# Only possible with the help of XDA forum members, Mostly E:V:A for the Baseband fix, he reminded me that I have two
# chains of trust in this SoC based device, one for the AP (application Processor) and one for the CP (Communication Processor)
# Tested Only ON SHV-E160L device but may work for other Qualcomm devices, replace the loaders with the correct ones for you device
# Samsung partition only, HTC has differing partition information
# see brixfix.sh for more info
# there are many reasons why you may have the baseband unknown failure, this fix is for a particular error on my SHV-E160L
# that i have tried to document on 
# http://forum.xda-developers.com/showthread.php?t=1914359
# please be aware of the dangers beefore using this file
# if you have your own recovery option installed and it supports ADB the you dont need to install the included recovery option
# *#06# does not seem to work in this device
# see shv-e160l-dial-codes.txt for alternatives
# included are ODIN recovery flash, Recovery mode flash update, dialer code, boot chain, adb for linux & windows
# please make sure you have all the other required files.

# WARNINGS
# This script can brick a device beyond software access repair, JTAG would be required or you need to find the EMMCBOOT resistor and short the low 
# side to ground

mkdir backup

# for windows use md backup
# md backup

#back-up  script
echo "Backing up Bootloaders"
echo
echo " if any of the following fail with errors do no reboot your device, correct the error and re-execute"
echo
adb shell dd if=/dev/block/mmcblk0p2 of=/sdcard/sbl1.mbn bs=512
adb pull /sdcard/sbl1.mbn backup/sbl1.mbn
adb shell dd if=/dev/block/mmcblk0p3 of=/sdcard/sbl2.mbn bs=512
adb pull /sdcard/sbl2.mbn backup/sbl2.mbn
adb shell dd if=/dev/block/mmcblk0p5 of=/sdcard/rpm.mbn bs=512
adb pull /sdcard/rpm.mbn backup/rpm.mbn
adb shell dd if=/dev/block/mmcblk0p6 of=/sdcard/sbl3.mbn bs=512
adb pull /sdcard/sbl3.mbn backup/sbl3.mbn
adb shell dd if=/dev/block/mmcblk0p7 of=/sdcard/aboot.mbn bs=512
adb pull /sdcard/aboot.mbn backup/aboot.mbn
adb shell dd if=/dev/block/mmcblk0p9 of=/sdcard/tz.mbn bs=512
adb pull /sdcard/sbl1.mbn backup/tz.mbn

#push bootloaders to device
echo "Copying bootloaders to device - /sdcard/"
echo
echo
adb push SHV-E160L/sbl1.mbn /sdcard/sbl1.mbn
adb push SHV-E160L/sbl2.mbn /sdcard/sbl2.mbn
adb push SHV-E160L/rpm.mbn /sdcard/rpm.mbn
adb push SHV-E160L/sbl3.mbn /sdcard/sbl3.mbn
# dont restore aboot.mbn but it's listed here for completeness
# adb push SHV-E160L/aboot.mbn /sdcard/aboot.mbn
adb push SHV-E160L/tz.mbn /sdcard/tz.mbn

# exit here if user not removed the exit code, user must read and understand documentation
# remove the following exit line after you confirmed the above has work without error

#exit

#restore 
echo 
echo "Copying Bootloaders to MMC"
echo " Restoring Chain of trust"
adb shell dd if=/sdcard/sbl1.mbn of=/dev/block/mmcblk0p2 bs=512
adb shell dd if=/sdcard/sbl2.mbn of=/dev/block/mmcblk0p3 bs=512
adb shell dd if=/sdcard/rpm.mbn of=/dev/block/mmcblk0p5 bs=512
adb shell dd if=/sdcard/sbl3.mbn of=/dev/block/mmcblk0p6 bs=512
# dont restore aboot.mbn but it's listed here for completeness
# adb shell dd if=/sdcard/aboot.mbn of=/dev/block/mmcblk0p7 bs=512 
adb shell dd if=/sdcard/tz.mbn of=/dev/block/mmcblk0p9 bs=512

echo
echo "Restore complete, "
echo "if any error occurs please resolve the error and re-execute this script, dont reboot the phone or you could "
echo "end with a bootloop or worse a hang before aboot.mbn (little kernel/download mode loader) is executed and odin mode is activated"
echo "the hang will require JTAG or a hardware mod to reactivate QDload mode, you will then need to run brixfix.sh "

