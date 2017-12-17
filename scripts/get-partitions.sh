#!/bin/bash

if [ $(uname -m) == "x86_64" ]; then
	adb="../adb/64-bit/adb"
else
	adb="../adb/32-bit/adb"
fi

$adb root &>/dev/null	# Start the adb with root permissions and hide the output
echo "$(tput bold)Connect the device with adb debugging enabled$(tput sgr 0)"
timeout 60 $adb wait-for-any-device
if [ $? -eq 0 ]; then
	set -e
	echo "Pushing script to device (please permit superuser when prompted)"
	$adb shell su -c 'mount -o rw,remount /system'
	$adb push ../binaries/parted /system/bin/parted
	$adb shell su -c 'chmod 0755 /system/bin/parted'

	echo "Creating destination folder"
	model=$($adb shell getprop ro.product.model)
	if [ -z "$model" ]; then
		model="$HOME/Desktop/Device"
	else
    	model="$HOME/Desktop/$model"
	fi
	mkdir -p "$model"

	echo "Pulling partition table (please permit superuser when prompted)"
	$adb shell su -c 'parted /dev/block/mmcblk0 unit s print' > "$model/PartitionTableSectors.txt"
	$adb shell su -c 'parted /dev/block/mmcblk0 unit B print' > "$model/PartitionTableBytes.txt"

	echo "Removing script from device"
	$adb shell su -c 'rm -f /system/bin/parted'

	echo "Done, partition table location $(tput bold)$model$(tput sgr 0)"
else
	echo "Device not detected"
fi
read -n 1 -s -r -p "Press any key to exit..."
echo ""
exit 0
