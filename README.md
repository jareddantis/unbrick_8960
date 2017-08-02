unbrick_8960 (version 1.1)
=================================

## What is it?
 
This tool is designed to unbrick devices with Qualcomm chips MSM8960/8930 and APQ8064.
It only works with devices that are stuck in QDLOAD (`05c6:9008`) / SDBOOT (`05c6:9025`) mode.

## How do I use it?

1. Connect device to a USB port on a Linux PC.
2. Run `sudo ./unbrick.sh` in a terminal. Make sure it is executable (`chmod +x ./unbrick.sh`).
3. Follow on screen instructions.

## What does it do?

This tool will detect devices in QDLOAD mode, switch to DMSS protocol and upload a hex (converted to bin for this purpose).

The hex is then executed and the device switches to Streaming Protocol, at this point we write a .mbn file to the internal
eMMC chip, at the end of the emmc write process the device then reboots.

After the reboot re-running `unbrick.sh` with detect the device in the second stage for repair, 
the device's eMMC is accessible as an SD card, we then write back the damaged parts of the bootchain.

You must write a new partition table or the device will always boot in SD card mode.

**WARNING:** Failure to write the rest of the boot chain could leave your device in a dead state
with only a black screen, no USB mode. The only way around that is through JTAG, or finding the boot resistor
which switches the device back to QDLOAD mode, or emergency boot.

Go to [this XDA thread](http://forum.xda-developers.com/showthread.php?t=1914359) for further details.

## This tool doesn't work at all. What's the deal?

This happens a lot, actually. The truth is, the hex/mbn files for each chip usually differs for each phone; although the phones in question do have the same chip. This is why you should really be backing up these files before your device goes kaput.

Refer to the next section.

## My chip isn't listed. How do I get the files needed?

Unfortunately these files are only available through leaks, and as such are hard to come upon. If you do have the `MPRGxxxx.hex` file for your device and you only need the `xxxx_msimage.mbn`, [this guide](http://cellphonetrackers.org/wp-content/uploads/8x60_msimage.mbn_.txt) is worth a try. (You'll need Windows and the [QPST software suite](http://d-h.st/qAy) for this, though.)

Another option would be to point a friend with the exact same device as yours to the guide above and have him/her give you the backed up files.

If you really don't have files available, I regret having to say this but your only hope is, most probably, a JTAG box.

## Additional Tools (for developers) 

* `scripts/getpartbin.py` - Python script for backing up the primary partition & extended partition tables and combines them into a
writable parition0.bin file
* `scripts/qdload.pl` - Perl script for talking in the HDLC framed DMSS & Streaming Protocols used by Qualcomm
* `scripts/get-part.sh` - **UNFINISHED** script by darkspr1te for creating partition tables in sfdisk format and .csv format
(to be used in the future to create partition0.bin plus more automated collection)
* `scripts/get-partitions.sh` - Script for pulling the partition table from a **working** device
* `scripts/backup.sh` - Script for pulling needed partitions from a **working** device
* `binaries/` - Folder containing armv5 (armv7 compatible) tools for partition manipulation and data collection
* `binaries/hex2bin` - convert your xxxxMPRG.hex file to bin for use with qdload
* `qpst-drivers/` - Windows drivers (only included for convenience)

## Credits

* [darkspr1te](https://github.com/mohammad92) for the original MSM8660 tool (`brixfix`)
* E:V:A
* SLS
* JCSullins (RootzWiki)
* Adam Outler
