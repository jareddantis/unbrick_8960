#!/bin/bash
adb="../adb/adb"

chmod 0755 $adb

echo "Waiting for device"
$adb wait-for-device

echo "Pushing script to device"
$adb push dump.sh /sdcard/dump.sh
$adb shell mount -o rw,remount /system
$adb shell cp /sdcard/dump.sh /system/xbin/dump.sh
$adb shell chmod 0755 /system/xbin/dump.sh

echo "Executing script (please permit superuser when prompted)"
$adb shell su -c /system/xbin/dump.sh

echo "Pulling partitions"
devm=$($adb shell getprop ro.product.model)
mkdir $devm
cd $devm
$adb pull /sdcard/unbrick
chmod -R 0777 *

echo "Moving pulled files to devices/$devm"
cd ../
mv $devm ../devices

echo "Done."
exit 0
