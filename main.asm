#include "kernel.inc"
#include "corelib.inc"

    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 40
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "progcalc", 0
start:
    
    ;Get a lock on the devices we intend to use
    pcall(getLcdLock)
    pcall(getKeypadLock)

    ;Allocate and clear a buffer to store the contents of the screen
    pcall(allocScreenBuffer)

    ;Load dependencies
    kld(de, corelibPath)
    pcall(loadLibrary)

    pcall(clearBuffer)
    kcall(drawScreen)

.loop:
    ;Copy the display buffer to the actual LCD
    pcall(fastCopy)

    ;flushKeys waits for all keys to be released
    pcall(flushKeys)
    ;waitKey waits for a key to be pressed, then returns the key code in A
    pcall(waitKey)

    kcall(checkKeys)

    kcall(drawScreen)
    cp kMode
    jr nz, .loop
    ; Exit when the user presses "MODE"

    ret

removeDigit:
    push af
    push de
    push bc
    push ix
    push hl

        ;Load into ACIX
        kld(hl, (upperWord))
        ld a, h
        ld c, l
        kld(ix, (lowerWord))

        ;Shift over one decimal place
        push af
            kld(a, (numberBase))
            cp 0
            jr z, .decimalShift
            cp 1
            jr z, .hexShift
            cp 2
            jr z, .binaryShift
.decimalShift:
            ld de, 0x0A
            jr .endShift
.hexShift:
            ld de, 0x10
            jr .endShift
.binaryShift:
            ld de, 0x02
            jr .endShift
.endShift:
        pop af
                        
            push iy
                ld iyh, b
                pcall(div32By16)     ;Divide ACIX by 10...
                ld b, iyh
            pop iy

        ld d, a
        ld e, c
        kld((upperWord), de)
        kld((lowerWord), ix)
    pop hl
    pop ix
    pop bc
    pop de
    pop af
    ret

addDigit:
    push af
    push de
        ;Shift over one decimal place
        kld(hl, (upperWord))
        ld d, h
        ld e, l
        kld(hl, (lowerWord))
        push af
            kld(a, (numberBase))
            cp 0
            jr z, .decimalShift
            cp 1
            jr z, .hexShift
            cp 2
            jr z, .binaryShift
.decimalShift:
            ld a, 0x0A
            jr .endShift
.hexShift:
            ld a, 0x10
            jr .endShift
.binaryShift:
            ld a, 0x02
            jr .endShift
.endShift:
            pcall(mul32By8)
        pop af
        push hl
            ld h, d
            ld l, e
            kld((upperWord), hl)
        pop hl
        kld((lowerWord), hl)       

        ld b, a
        
        ld a, d
        ld c, e
        kld(ix, (lowerWord))
        ;add the new number
        ld d, 0
        ld e, b
        ;kld(hl, (upperWord))
        ;ld a, h
        ;ld c, l
        ;kld(hl, (upperWord))
        ;ld ixh, h
        
        pcall(add16To32)
        ld h, a
        ld l, c
        kld((upperWord), hl)
        kld((lowerWord), ix)
    pop de
    pop af
    ret




;; mvNewToOld
;;  Moves the new number into the old number
;;  Sets the new number to zero
;; Inputs:
mvNewToOld:
    push hl
       kld(hl, (upperWord))
       kld((oldUpperWord), hl)
       kld(hl, (lowerWord))
       kld((oldLowerWord), hl)
       ;clear newNumber
       ld hl, 0
       kld((upperWord), hl)
       kld((lowerWord), hl)
    pop hl
    ret


#include "calculate.asm"
#include "drawScreen.asm"
#include "keys.asm"
#include "mathSelect.asm"
menu:
    .db 3
    .db "Decimal", 0
    .db "Hex", 0
    .db "Binary", 0
windowTitle:
    .db "Programming Calculator", 0
corelibPath:
    .db "/lib/core", 0
numberBase:
    .db 0

operator:
    .db 0
upperWord:
    .dw 0
lowerWord:
    .dw 0

oldUpperWord:
    .dw 0
oldLowerWord:
    .dw 0

