# progcalc
A programmer's calculator for KnightOS









To add progcalc to the Castle homescreen, go to /KnightOS/config/castle.conf.asm

change one of the blank apps from

.dw 0xFFFF

to this:

.dw progcalcStr, progcalcPath
.db 0xff, 0xff, 0x80, 0x01, 0xa0, 0x01, 0xa0, 0x01
.db 0xa0, 0x01, 0x84, 0x21, 0x84, 0x21, 0x84, 0x21
.db 0x87, 0xe1, 0x84, 0x21, 0x84, 0x21, 0x84, 0x21
.db 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0xff, 0xff

At the bottom of the file, add 

progcalcStr:
    .db "Programming Calc", 0
progcalcPath:
    .db "/bin/progcalc", 0

Then from the KnightOS repository root directory, run the following command to compile your configurations:

sass config/castle.conf.asm config/castle.conf

