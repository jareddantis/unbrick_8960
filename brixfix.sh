#!/bin/bash
#This is to dump $MODEL firmware to the phone using only system files and backups of bootloaders etc 
# Written By darkspr1te with the help of dev's from xda forums, Scotty, Adam ,E:V:A, JCSullins and more
# This is a early stage version, watch for bugs
# 
# use fdisk -l /dev/sd? to check for partitons
QDLOADID="05c6:9008"
DLOADID="05c6:9008"
SDMODE="05c6:9025"
MODEL="SCH-I535-16GB"
DEVICEID=/dev/disk/by-id/usb-Qualcomm_MMC_Storage-0\:0

DEVICE=`ls -lah /dev/disk/by-id/ | grep usb\-Qualcomm_MMC | head -n 1 | awk '{ print $11 }' | sed 's/\..\/..//'`
USBNAME=`lsusb | grep Qualcomm  ` 
USBID=`lsusb | grep Qualcomm  | awk '{ print $6 }'` 
echo 
echo -e "\033[38;5;148mBrick Fix v2-0\033[39m"
echo "______________"
echo -e "By Darkspr1te, See README for thanks & References"
echo -e
echo -e "Checking For Qualcomm Device"
if test "$USBID" = "$DLOADID" 
	then 
		choice="n"
		echo -e "Device Found !!!"
		echo -e "\e[00;31mError:\e[00m device found in QDLOAD Mode, switching to QDLOAD "
		echo "see qdload.pl By JC Sullins , http://github.com/jcsullins/qdloader"
		echo 
		echo "Expected VID/PID of 05c6:9025, Instead I get :-"
		echo -e "\e[00;33m$USBNAME\e[00m"
		echo 
		echo -e "Do you wish to Upload HEX & msimage.mbn now? \e[00;31mWarning Dangerous\e[00m"
		read -n 1 choice
		if [ $choice == "y" ]
		 then
			echo
		    echo "Executing qdload "
		    #exit
			perl qdload.pl -pfile MPRG8960.hex -lfile 8960_msimage.mbn -lreset
			echo 
			echo "If HEX/MBN uploaded correctly, please allow for short delay and re-run brixfix to continue the debricking session, a screen showing device options may appear, close this new screen"
			exit 
			else
				echo
				echo "Operation cancelled at user request"
				exit 1
			fi
	else
		echo "No QDLOAD device found, checking for SD-CARD Mode "
	fi
	
#echo
# echo "read the README before using brixfix"
#echo 
#cat brixfix.sh
#exit
#echo -e "\e[00;44mTest Vars \e[00;31m"
#echo $DEVICEID
#echo $DEVICE
#echo $USBID
#echo $USBNAME
#echo
echo -e -n "\e[00m"
if test "$USBID" = "$SDMODE" 
	then
		echo -e "Device found !!!!"
		echo -e "Mode is SD-CARD/msimage mode at device node /dev$DEVICE"
		echo -e "With USB PID/VID ID of \e[00;44m$USBID\e[00;31m"
		echo -e -n "Detailed Output is "
		echo -e "\e[00;33m$USBNAME\e[00m"
		#set -x
 
		#The following Two lines write back the MBR to sector 0 and EBF to sector 208801
		# This is required to restore your partiton table so the the iROM code can find the loaders
		echo
		echo -e "Do you wish to write parititon \e[00;31mWarning Dangerous\e[00m"
		read -n 1 choice
		echo
		if [ $choice == "y" ]
			then
				echo "Writing parititon to /dev$DEVICE"
				dd  if=$MODEL/partition0.bin of=/dev$DEVICE seek=0 count=1 bs=512 
				dd  if=$MODEL/partition0.bin of=/dev$DEVICE skip=1 seek=208801 count=22 bs=512
				choice="n"
				echo 
			fi
#SMD_HDR partition is unknown to me at this time , leave commented out with the #
# dd  if=smd_hdr.mbn of=/dev/sdb  of=/dev/sdb  seek=1  count=102400 bs=512 


#This next few lines are bootloader repair, all files reuired to get basic ODIN mode only
#If you know what is currupt then only flash that file
#otherwise remove the hash # in front off dd up until end of bootloader section
##
		echo -e "Do you wish to write bootloaders \e[00;31mWarning Dangerous\e[00m"
		read -n 1 choice
		echo 
		if [ $choice == "y" ]
			then
				echo "Writing bootloaders sbl1,sbl2,sbl3,rpm,aboot to /dev$DEVICE"
				dd  if=$MODEL/sbl1.mbn of=/dev$DEVICE  seek=131072 count=500 bs=512
				dd  if=$MODEL/sbl2.mbn of=/dev$DEVICE  seek=131328 count=1500 bs=512
				dd  if=$MODEL/sbl3.mbn of=/dev$DEVICE  seek=131840 count=2048 bs=512
				dd  if=$MODEL/aboot.mbn of=/dev$DEVICE  seek=132864 count=2500 bs=512
				dd  if=$MODEL/rpm.mbn of=/dev$DEVICE  seek=136960 count=500 bs=512
				choice="n"
				echo
			fi
		
# boot.img only needed if it's damaged on the device, for base ODIN/LOKE interaction you only need sbl1,2,3,rpm,tz,aboot files.
# dd  if=$MODEL/boot.img of=/dev/sdb  seek=237568 count=10240 bs=512 

			echo -e "Do you wish to write TrustZone \e[00;31mWarning Dangerous\e[00m"
			read -n 1 choice
			echo
			if [ $choice == "y" ]
				then
					echo "Writing TrustZone to /dev/$DEVICE"
					dd  if=$MODEL/tz.mbn of=/dev$DEVICE  seek=158464 count=500 bs=512 
					choice="n"
			fi

	echo 
	echo "If no errors occured then disconnect and remove/replace battery, if ANY error occured do not disconnect device, fix error and rerun or seek advice !!"
### End of bootloaders



	else
		echo -e "\e[00;31mError:\e[00m No Qualcomm Device found, pease check cables, run lsusb and verify the device is connected"
		echo "Program cannot continue, sorry."
		echo
		exit 1
	fi
	
exit



#do not use the options past here- development only --YOU HAVE BEEN WARNED --
exit
# dd  if=SSD of=/dev/sdb seek=270336 count=500 bs=512
# dd  if=$MODEL.pit of=/dev/sdb  seek=278528 count=500 bs=512 
# dd  if=param.lfs of=/dev/sdb  seek=286720 count=10240 bs=512 
# dd  if=patch/amss.bin of=/dev/sdb  seek=311296  count=100352 bs=512 
# dd  if=efs.img of=/dev/sdb  seek=516096  count=3072 bs=512 
# dd  if=MSM_STG2 of=/dev/sdb  seek=524288  count=3072 bs=512 
# dd  if=MSM_FSG of=/dev/sdb  seek=532480  count=3072 bs=512 
# dd  if=patch/mdm.bin of=/dev/sdb  seek=540672  count=100352 bs=512 
# dd  if=efsclear1.bin of=/dev/sdb  seek=745472  count=3072 bs=512 
# dd  if=efsclear2.bin of=/dev/sdb  seek=753664  count=3072 bs=512 
# dd  if=M9K_FSG of=/dev/sdb  seek=761856  count=3072 bs=512 
# dd  if=enc.img.ext4 of=/dev/sdb  seek=770048  count=10240 bs=512 
# dd  if=patch/recovery.img of=/dev/sdb  seek=794624  count=10240 bs=512 
# dd  if=patch/system.img.ext4 of=/dev/sdb  seek=843776  count=1533952 bs=512 
# dd  if=patch/cache.img.ext4 of=/dev/sdb seek=8118272 count=309248 bs=512
#set +x
