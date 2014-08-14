import os
from struct import *

def mbr():
	global offset, partitions
	os.popen("adb shell su -c 'dd if=/dev/block/mmcblk0 of=/cache/partition0.bin bs=512 count=1'").close()
	os.popen("adb shell su -c 'cp /cache/partition0.bin /sdcard/partition0.bin'").close()
	os.popen("adb pull /sdcard/partition0.bin .").close()
	f =  open("partition0.bin", 'rb')
	data = f.read()
	f.close()
	partitions = [ ]
	n=0
	while True:
		buf = data[446+(16*n):446+(16*(n+1))]
		partition = dict(zip(('boot', 'id', 'start', 'size'), unpack('4I', buf)))
		partition['type'] = "MBR"
		n += 1
		partition['no'] = n
		partitions.append(partition)
		if partition['id'] == 5:
			offset = partition['start']
			break

def ebr():
	global offset, partitions
	n = 0
	while True:
		a = 0
		os.popen("adb shell su -c 'dd if=/dev/block/mmcblk0 of=/cache/ebr bs=512 count=1 skip=" + str(offset+n) + "\'").close()
		n += 1
		os.popen("adb shell su -c 'dd if=/cache/ebr of=/cache/partition0.bin bs=512 count=1 seek=" + str(n) + "'").close()
		os.popen("adb shell su -c 'cp /cache/ebr /sdcard/partition0.bin'").close()
		os.popen("adb pull /sdcard/partition0.bin .").close()
		f = open("partition0.bin", 'rb')
		data = f.read()
		f.close()
		while True:
			buf = data[446+16*a:446+16*(a+1)]
			partition = dict(zip(('boot', 'id', 'start', 'size'), unpack('4I', buf)))
			if partition['id'] == 5:
				break
			if partition['id'] == 0:
				return
			partition['type'] = "EBR"
			partition['no'] = n
			partition['start'] += n-1+offset
			partitions.append(partition)
			a += 1


if __name__ == "__main__":
	mbr()
	ebr()
	os.popen("adb shell su -c 'cp /cache/partition0.bin /sdcard/partition0.bin'").close()
	os.popen("adb pull /sdcard/partition0.bin .").close()
	for part in partitions:
		print "%s %2i, Boot: 0x%02X, Id: 0x%02X, Start: 0x%08X (%8i), Size: 0x%08X (%8i, %8i KB)" % (part['type'], part['no'], part['boot'], part['id'], part['start'], part['start'], part['size'], part['size'], part['size']/2)
