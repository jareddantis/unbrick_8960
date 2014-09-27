unbrick_8960
=================================

## What is it?
 
This tool is designed to repair devices with Qualcomm chips MSM8660/MSM8960.
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
with only a black screen, no USB enumeration. The only way around that is JTAG, or finding the boot resistor
which switches the device back to QDLOAD mode, or emergency boot.

Go to [this XDA thread](http://forum.xda-developers.com/showthread.php?t=1914359) for further details.


## Additional Tools (DEV Level) 

* `getpartbin.py` - A Python script for backing up the primary partition & extended partition tables and combines them into a
writable parition0.bin file (python)
* `qdload.pl` - A Perl script for talking in the HDLC framed DMSS & Streaming Protocols used by Qualcomm
* `switchmode.sh` - Executes qdload.pl for msm8660 device upload
* `get-part.sh` - **UNFINISHED** tool by darkspr1te for creating partition tables in sfdisk format and .csv format
(to be used in the future to create partition0.bin plus more automated collection)
* `tools/` - Folder containing armv5 (arm7 compatible) tools for partition manipulation and data collection
* `ADB/` - Folder containing adb programs
* `extras/` - Folder containing odin and clock work mode recovery installers for 160l devices 
* `Qualcomm/` - Windows drivers (For QPST, Not required in linux, included for backwards compatability with older guides)
* `hex2bin` - convert your xxxxMPRG.hex file to bin for use with qdload
 
## Credits

* [darkspr1te](https://github.com/mohammad92) for the original tool (`brixfix`)
* E:V:A
* SLS
* JCSullins (RootzWiki)
* Adam Outler
