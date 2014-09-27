unbrick_8960 version 1.1
=================================

## What is it?
 
This tool is designed to repair devices with the Qualcomm chip MSM8960.
It only works with devices that are stuck in QDLOAD (`05c6:9008`) / SDBOOT (`05c6:9025`) mode.
Windows users, please see `readme-win.txt`.

## How do I use it?

1. Connect device to USB port on a Linux PC. **Not tested under Windows via USB redirection!**
2. Run `sudo ./unbrick.sh` in a terminal.
3. Follow on screen instructions.

## What does it do?

This tool will detect device in QDLOAD mode and switch to DMSS protocol and upload a hex (converted to bin for this purpose).

The hex is then executed and the device switches to Streaming Protocol, at this point we write a .mbn file to the internal
emmc chip, at the end of the emmc write process the device then reboots.

After the reboot re-running brixfix with detect the device in the second stage for repair, 
the device's emmc is accssable as an SD card, we then write back the damaged parts of the bootchain.

You must write a new partition table or the device will always boot in SD card mode.

**WARNING:** Failure to write the rest of the boot chain could leave your device in a dead state
with only a black screen, no USB mode. The only way around that is through JTAG, or finding the boot resistor
which switches the device back to QDLOAD mode, or emergency boot.

Go to [this XDA thread](http://forum.xda-developers.com/showthread.php?t=1914359) for further details.


## Additional Tools (DEV Level) 

* `scripts/getpartbin.py` - Python script for backing up the primary partition & extended partition tables and combines them into a
writable parition0.bin file (python)
* `scripts/qdload.pl` - Perl script for talking in the HDLC framed DMSS & Streaming Protocols used by Qualcomm
* `scripts/get-part.sh` - **UNFINISHED** script by darkspr1te for creating partition tables in sfdisk format and .csv format
(to be used in the future to create partition0.bin plus more automated collection)
* `scripts/backup.sh` and `scripts/backup.bat` - Scripts for pulling needed partitions from a **working** device
* `binaries/` - Folder containing armv5 (arm7 compatible) tools for partition manipulation and data collection
* `binaries/hex2bin` - convert your xxxxMPRG.hex file to bin for use with qdload
* `adb/` - Folder containing adb programs
* `qpst-drivers/` - Windows drivers (For QPST, Not required in linux, included for backwards compatability with older guides)

 
## Credits

* [darkspr1te](https://github.com/mohammad92) for the original MSM8660 tool (`brixfix`)
* E:V:A
* SLS
* JCSullins (RootzWiki)
* Adam Outler
