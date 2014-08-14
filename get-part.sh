#########
###get-part.sh is a unfinised tool for collecting the partition data from samsung/qualcomm based devices 
#### BETA v1
echo -e "\033[38;5;148mGet Partition Specs v1-0\033[39m"
echo "______________"
echo -e "By Darkspr1te, See README for thanks & References"

#/bin/bash
tools=`adb shell su -c "find /data/loader/sfdisk"`
testtools="find:"
model=`adb shell getprop ro.product.model | sed '$s/.$//'`-`adb shell getprop ro.board.platform | sed '$s/.$//'`
line=0

#echo $tools
#exit
#echo $testtools

installtools ()
{
echo "Installing Tools"
adb shell su -c "mkdir /data/loader"
adb push ../tools/sfdisk /data/loader
adb shell su -c "chmod 744 /data/loader/sfdisk"
}


parsecsv ()
{
	skipline=`cat $model-partition.txt | grep -n "unit" | cut -c1-1` # find the word sectors note it's line number for tail skip later
	let skipline=skipline+1 # skip one more so we start with empty line

#debug
#echo $skipline

#for line in $(cat $model-partition.txt); do 
#Debug line for testing sscrips sed fileters
#does not count for bootable attrib and part id has double ,, - fixed 

# echo "partition number             start       size    id   bootable flag" # not written to csv file
# echo "/dev/block/mmcblk0p1  ,         1  ,    204800  , 92" # to test layout spacing

	old_IFS=$IFS      # save the field separator           
	IFS=$'\n'     # new field separator, the end of line  
	if [ -f $model-partition.csv ];
		then
			rm $model-partition.csv # remove old file as csv parser will just fill it up
	fi
	for line in $(sed 's/://' $model-partition.txt | sed "s/=/\,/g" | sed "s/,/\ /g" | tail -n +$skipline | sed "s/start/\,/g" | sed "s/size/\,/g" | sed "s/Id/\,/g" | sed "s/bootable/\,*/g" | tr -d '\001'-'\011''\013''\014''\016'-'\037''\200'-'\377'); do
		{

		linetxt=`echo -En "$line" |  sed 's/\r//g' | sed 's/ //g'`
		idtxt=`echo -En "$line" | awk '{print $7}' | sed 's/\r//g'`
		bootflag=`echo "$linetxt" | awk 'BEGIN { FS = "," } ;{print $5}' |sed 's/\r//g'`
		#echo "$bootflag"
		if [ "$bootflag" == "*" ]
		 then 
		 	 linetxt=`echo -En "$line" |  sed 's/\r//g' | sed 's/ //g' | sed 's/\,\*//g'`
				 fi
		 
		case "$idtxt" in
		92)
			csvstring=",HLOS-BIN"
			;;
		4d)
			csvstring=",SBL1"
			;;
		51)
			csvstring=",SBL2"
		;;
		5)
			csvstring=",EXT"
		;;
		47)
			csvstring=",RPM"
		;;
		45)
			csvstring=",SBL3"
		;;
		4c)
			csvstring=",ABOOT"
		;;
		48)
			csvstring=",BOOT"
			;;
		46)
			csvstring=",TZ"
			;;
		5d)
			csvstring=",SSD"
			;;
		91)
			csvstring=",PIT"
			;;
		93)
			csvstring=",PARAM"
			;;
		c)
			csvstring=",MODEM"
			;;
		4a)
			csvstring=",MSM_ST1"
			;;
		4b)
			csvstring=",MSM_ST2"
			;;
		58)
			csvstring=",MSM_FSG"
			;;
		8f)
			csvstring=",MDM"
			;;
		59)
			csvstring=",M9K_EFS1"
			;;
		5a)
			csvstring=",M9K_EFS2"
			;;
		5b)
			csvstring=",M9K_FSG"
			;;
		ab)
			csvstring=",DEVENC"
		;;
		60*)
			csvstring=",RECOVERY"
		;;
		94*)
			csvstring=",FOTA"
		;;
		a5*)
			csvstring=",SYSTEM"
		;;
		a6*)
			csvstring=",USERDATA"
		;;
		a8*)
			csvstring=",CACHE"
		;;
		a9*)
			csvstring=",TOMBSTONES"
		;;
		95*)
			csvstring=",HIDDEN"
		;;
		90*)
			csvstring=",UMS"
		;;
	
		esac
		echo -en "$linetxt"  >> $model-partition.csv
		echo -en "$csvstring" >> $model-partition.csv
		if [ "$bootflag" == "*" ]; then 
			{
				echo ",bootable" >> $model-partition.csv
			}
		else 
			{
			echo "" >> $model-partition.csv
			}
		fi
			
		}
	done
	IFS=$old_IFS     # restore default field separator 
}


transpose ()
{
	awk '{ print $3 }'
	for line in $(cat $model-partition.csv); do
	echo 
	done
		
}

extractpit ()
{
	for line in $(cat $model-partition.csv); do
		{
			partid=`echo $line | awk '{print $1}'`
			echo "$partid"
		}
	done
	echo "donepit"
}
#main function
# Test to see if find returns file found or not, if fails first text is find: if success returns location of file - quit and dirty if exists for adb bridge - requires busybox 
if  [[ "$tools" == *"$testtools"* ]]; then
		installtools
	else
		echo "Tools Already Present- Skipping"
	fi

echo -n "Device Model "
echo $model

adb shell su -c "/data/loader/sfdisk -d /dev/block/mmcblk0" > $model-partition.txt
parsecsv
extractpit
echo "done"


