include .knightos/variables.make

# This is a list of files that need to be added to the filesystem when installing your program
ALL_TARGETS:=$(BIN)progcalc $(APPS)progcalc.app $(SHARE)icons/progcalc.img

# This is all the make targets to produce said files
$(BIN)progcalc: *.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(BIN)progcalc

$(APPS)progcalc.app: config/progcalc.app
	mkdir -p $(APPS)
	cp config/progcalc.app $(APPS)

$(SHARE)icons/progcalc.img: config/progcalc.png
	mkdir -p $(SHARE)icons/
	kimg -c config/progcalc.png $(SHARE)icons/progcalc.img

include .knightos/sdk.make
