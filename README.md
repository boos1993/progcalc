# progcalc
This is a programmer's calculator for KnightOS.



## Functionality

It currently supports 32bit  Decimal, Hexadecimal and Binary entry and conversion. 

For the mathematical operations, the first number that is entered is always 32bit while the second number will be truncated before the operation.

- Addition
	- 32bit + 16bit
- Subtraction
	- 32bit - 16bit
- Multiplication
	- 32bit * 8bit
- Division
	- 32bit / 16bit

## Keybindings
***In keys.asm, set DEBUG to 0 for running on hardware or to 1 for running with the z80 emulator***

|Function			| OnCalc	|z80e			|
|-----------------------------|:---------------:|:---------------------:|
|Back to Castle 	| Y=		|F1				|
|Delete Digit	 	| Del		|F2				|
|Open Base Menu	| Zoom	|F3				|
|Clear Entry	 	| Clear		|F4				|
|Thread Switcher	| Graph	|F5				|
|Add			 	| +			|Right Arrow	|
|Subtract		 	| -			|Left Arrow	|
|Multiply			| x			|Up Arrow		|
|Divide			| /			|Down Arrow	|
|Enter				|Enter		|Enter/Return	|
|Quit				|Mode		|ESC			|


## Compiling
***Requires a version of the kernel that includes drawDecHL and drawDecACIX. ***

First, install the [KnightOS SDK](http://www.knightos.org/sdk).

Then in the base directory of this repository, run

    $ knightos init progcalc
    $ make
    $ make run

Use this command to compile the kernel from source
   
    $ knightos init --kernel-source=/path/to/kernel progcalc

    
## Installing

###Using SDK

The package can be found at [packages.knightos.org](https://packages.knightos.org/community/progcalc) and installed using:

    $ knightos install community/progcalc

###Manual
Use `make package` to get a package that you can install.

To install the package in [KnightOS](https://github.com/KnightOS/KnightOS) run

    $ make install PREFIX=../KnightOS/.knightos/pkgroot/

To "pin" the application to castle, add this to the makefile in [KnightOS](https://github.com/KnightOS/KnightOS) directory. Put it right after the other "pin" lines.

    ln -s /var/applications/progcalc.app $(VAR)castle/pin-7
