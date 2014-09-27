#!/bin/bash
QDLOADID="05c6:9008"
DLOADID="05c6:9008"
SDMODE="05c6:9025"
DEVICEID=/dev/disk/by-id/usb-Qualcomm_MMC_Storage-0\:0
DEVICE=`ls -lah /dev/disk/by-id/ | grep usb\-Qualcomm_MMC | head -n 1 | awk '{ print $11 }' | sed 's/\..\/..//'`
USBNAME=`lsusb | grep Qualcomm  ` 
USBID=`lsusb | grep Qualcomm  | awk '{ print $6 }'` 

chmod 0755 binaries/*
chmod 0755 scripts/*
chmod -R 0755 adb/*
chmod -R 0777 devices/*
chmod -R 0777 hexmbn/*

printf '\033c'
if [ $(whoami) != "root" ]; then
	echo -e "\e[00;31mError:\e[00m Not running as root. Exiting."
	exit 1
fi

echo ""
echo -e "\033[38;5;148munbrick_8960 v1.1\033[39m"
echo ""
echo "Originally by Darkspr1te, forked by aureljared."
echo "See README for credits."
echo "---------------------------------------------"
echo ""

echo "Available device files:"
ls devices/
echo ""
echo -n "Enter your device model from above, case-sensitive: "
read MODEL
if [ ! $(ls devices/ | grep $MODEL) ]; then
	echo ""
	echo "Invalid device model! Exiting."
	exit 1
else
	MODELDIR="devices/$MODEL"
fi
echo "---------------------------------------------"
echo ""
echo "Supported chips:"
ls hexmbn/chips/
echo ""
echo -n "Enter your chip model from above, case-sensitive: "
read chip
if [ $chip == "msm8930" ]; then
	appendchip="8930"
elif [ $chip == "msm8960" ]; then
	appendchip="8960"
elif [ $chip == "apq8064" ]; then
	appendchip="8064"
else
	echo ""
	echo "Invalid chip model! Exiting."
	exit 1
fi

printf '\033c'
echo -n "Checking for Qualcomm devices in QDLOAD mode... "
if [ $USBID == $DLOADID ]; then 
	echo -e "found!"
	choice="n"
	
	echo -e -n "\nDo you wish to upload MPRG$appendchip.hex & "$appendchip"_msimage.mbn now? [y/n]: "
	read -n 1 choice
		
	if [ $choice == "y" ]; then
		echo -e "\nExecuting qdload.pl..."
		echo ""
		perl scripts/qdload.pl -pfile $chip/MPRG$appendchip.hex -lfile $chip/"$appendchip"_msimage.mbn -lreset
		echo ""
		echo "If HEX/MBN uploaded correctly, please wait a while and re-run unbrick.sh"
		echo "to continue the unbricking session. A screen showing device options may appear;"
		echo "close this new screen."
		echo ""
		echo "If there was any error, do NOT disconnect device (or else you might not"
		echo "get it to connect anymore)! Try running script again."
		exit 0
	else
		echo ""
		echo "Operation cancelled. Exiting."
		exit 1
	fi
else
	echo -e "not found.\n"
fi

echo -e -n "\e[00m"
echo -n "Checking for Qualcomm devices in SDBOOT mode... "
if [ $USBID == $SDMODE ]; then
	echo -e "found!"
	echo -e "\nLocation: device node /dev$DEVICE"
	echo -e "with USB PID/VID ID of \e[00;44m$USBID\e[00;31m"
	echo "Detailed output is"
	echo -e "\e[00;33m$USBNAME\e[00m"
 
	# Write back the MBR to sector 0 and EBF to sector 208801
	echo ""
	echo "Do you wish to write the MBR? \e[00;31mWarning, dangerous!\e[00m"
	read -n 1 choice
	echo ""
	if [ $choice == "y" ]; then
		echo "Writing to /dev$DEVICE"
		dd if=$MODELDIR/partition0.bin of=/dev$DEVICE seek=0 count=1 bs=512 
		dd if=$MODELDIR/partition0.bin of=/dev$DEVICE skip=1 seek=208801 count=22 bs=512
		
		choice="n"
		echo ""
	fi

	# SMD_HDR seems to be the modem partition, uncomment at your own risk
	# dd if=smd_hdr.mbn of=/dev/sdb seek=1 count=102400 bs=512 

	# These next few lines are for bootloader repair (to get ODIN mode).
	# If you know what is corrupt then flash only that file.
	echo -e "Do you wish to write bootloaders? \e[00;31mWarning, dangerous!\e[00m"
	read -n 1 choice
	echo ""
	if [ $choice == "y" ]; then
		echo "Writing bootloaders to /dev$DEVICE"
		echo " - secondary bootloader"
		dd if=$MODELDIR/sbl1.mbn of=/dev$DEVICE  seek=131072 count=500 bs=512
		dd if=$MODELDIR/sbl2.mbn of=/dev$DEVICE  seek=131328 count=1500 bs=512
		dd if=$MODELDIR/sbl3.mbn of=/dev$DEVICE  seek=131840 count=2048 bs=512
		echo "- AP bootloader"
		dd if=$MODELDIR/aboot.mbn of=/dev$DEVICE  seek=132864 count=2500 bs=512
		echo "- resource power manager"
		dd if=$MODELDIR/rpm.mbn of=/dev$DEVICE  seek=136960 count=500 bs=512
		
		choice="n"
		echo
	fi
	
	# boot.img only needed if it's damaged on the device.
	# dd if=$MODELDIR/boot.img of=/dev/sdb  seek=237568 count=10240 bs=512 

	echo -e "Do you wish to write TrustZone? \e[00;31mWarning, dangerous!\e[00m"
	read -n 1 choice
	echo
	if [ $choice == "y" ]; then
		echo "Writing TrustZone to /dev/$DEVICE"
		dd  if=$MODELDIR/tz.mbn of=/dev$DEVICE  seek=158464 count=500 bs=512
	fi

	echo ""
	echo "If no errors occurred then disconnect and reinsert battery."
	echo "If ANY error occurred, do not disconnect device, fix error and rerun or seek advice."
else
	echo "not found."
	echo ""
	echo -e "\e[00;31mError:\e[00m No Qualcomm device found. Check cables, run lsusb and verify the device is connected."
	echo ""
	exit 1
fi

unset -v choice

exit 0
