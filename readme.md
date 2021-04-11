# Apple II Running Wolf animation as a tribute

Dedicated to the guy who cracked "La bête du Gévaudan"
(A french video game on Apple II in the 80s)

It is written in assembly language only (Merlin).
Is show :

* In intro
* The running wolf animation

## Credits

* Christophe Meneboeuf : https://www.xtof.info/making-apple-ii-sing.html
* Music : James Bond theme (several notes)

## Features

* Works with ProDOS 8, it should work on DOS 3.3 (not tested with DOS 3.3 nor on GS)
* The program turns on 40 col. mode.
* Use the space bar to pause/unpause the animation
* Use another key to exit
* a lot of comments in source.

## Requirements to compile and run

Here is my configuration:

* Visual Studio Code with 2 extensions :

-> [Merlin32 : 6502 code hightliting](marketplace.visualstudio.com/items?itemName=olivier-guinart.merlin32)

-> [Code-runner :  running batch file with right-clic.](marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

* [Merlin32 cross compiler](brutaldeluxe.fr/products/crossdevtools/merlin)

* [Applewin : Apple IIe emulator](github.com/AppleWin/AppleWin)

* [Applecommander ; disk image utility](applecommander.sourceforge.net)

* [Ciderpress ; disk image utility](a2ciderpress.com)

Note :
DoMerlin.bat puts all things together. It needs a path to Merlin32 directory, to Applewin, and to Applecommander.
DoMerlin.bat is to be placed in project directory.
It compile source (*.s) with Merlin32, copy 6502 binary to a disk image (containg ProDOS), and launch Applewin with this disk in S1,D1.

tributeA2.s is ready to be compiled on a genuine Apple II, with Merlin 8.
It can be imported in a disk image using Ciderpress, then used on an Apple II (IIc in my case).
I use [Floppy emu](www.bigmessowires.com/floppy-emu) wich is really great, congratulation to Big Mess O'Wire !!!!
See "Merlin32 to apple II Merlin 8.txt" to know how to convert a Merin32 source to a Merlin 8 compatible source.

## Todo

* Port to DHGR
* More music, more graphics
