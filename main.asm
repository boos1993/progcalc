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
    
    ; Get a lock on the devices we intend to use
    pcall(getLcdLock)
    pcall(getKeypadLock)

    ; Allocate and clear a buffer to store the contents of the screen
    pcall(allocScreenBuffer)

    ; Load dependencies
    kld(de, corelibPath)
    pcall(loadLibrary)

    pcall(clearBuffer)
    kcall(drawScreen)

.loop:
    ; Copy the display buffer to the actual LCD
    pcall(fastCopy)

    ; flushKeys waits for all keys to be released
    pcall(flushKeys)
    ; waitKey waits for a key to be pressed, then returns the key code in A
    pcall(waitKey)

    kcall(checkKeys)

    kcall(drawScreen)
    cp kUp
    jr nz, .loop
    ; Exit when the user presses "MODE"

    ret

updateNumber:
    push af
    push de
        ;Shift over one decimal place
        kld(de, (upperWord))
        kld(hl, (lowerWord))
        push af
            ld a, 0x0A
            pcall(mul32By8)
        pop af
        kld((upperWord), de)
        kld((lowerWord), hl)       


        ;add the new number
        ld e, a
        ld d, 0
        kld(hl, (upperWord))
        ld a, h
        ld c, l
        kld(ix, (lowerWord))
        pcall(add16To32)
        ld h, a
        ld l, c
        kld((upperWord), hl)
        kld((lowerWord), ix)
    pop de
    pop af
    ret

drawScreen:
    pcall(clearBuffer)
    push af
    push de
    push hl
    push ix

        kld(hl, windowTitle)
        ld a, 0x04
        corelib(drawWindow)

        ld d, 4
        ld e, 10
        kld(hl, (upperWord))
        kcall(drawBits)

        push af
            ld a, d
            add a, 9
            ld d, a
        pop af
        ld h, l
        kcall(drawBits)

        ld d, 4
        ld e, 19
        kld(hl, (lowerWord))
        kcall(drawBits)

        push af
            ld a, d
            add a, 9
            ld d, a
        pop af
        ld h, l
        kcall(drawBits)

        ld d, 0
        ld e, 26
        ld h, 95
        ld l, 26
        pcall(drawLine)

        kld(a, (numberBase))
        cp 0
        jr z, .decimalDraw

        kld(a, (numberBase))
        cp 1
        jr z, .hexDraw

        kld(a, (numberBase))
        cp 3
        jr z, .binaryDraw

.binaryDraw:  
        ;Draw Binary
        ld d, 4
        ld e, 40
        kld(hl, (upperWord))
        pcall(drawHexHL)
        kld(hl, (lowerWord))
        pcall(drawHexHL)
        jr .endDraw
.hexDraw:  
        ;Draw Hex
        ld d, 4
        ld e, 40
        kld(hl, (upperWord))
        pcall(drawHexHL)
        kld(hl, (lowerWord))
        pcall(drawHexHL)
        jr .endDraw
.decimalDraw:     
        ;Draw Decimal
        ld d, 4
        ld e, 40
        kld(hl, (upperWord))
        ld a, h
        ld c, l
        kld(hl, (lowerWord))
        ld ixh, h
        ld ixl, l
        pcall(drawDecACIX)
        jr .endDraw
.endDraw:

    pop ix
    pop hl
    pop de
    pop af
    ret

;; drawBits [Text]
;;  Draws a byte to the screen
;; Inputs:
;;  H: Byte to be displayed
;;  A: Size of element
drawBits:
    push af
    ld a, 8
    .moreBits:
    dec a
    bit 7, h
    jr nz, .one

    ;draw a zero
    push af
        ld a, '0'
        pcall(drawChar)
    pop af
    jr .skipOne

    ;draw a one
    .one:
    push af
        ld a, '1'
        pcall(drawChar)
    pop af

    
    .skipOne:
    inc d ;add padding between bits
    SLA h ;shift left
    
    cp 0   
    jr nz, .moreBits

    pop af
    ret


checkKeys:
    push af

        cp kClear
        jr nz, _
        push de
        push hl
            ld de, 0x0000
            ld hl, 0x0000
            kld((upperWord), de)
            kld((lowerWord), hl)
            ld a, 0
            kcall(updateNumber)
            kcall(drawScreen)
        pop hl
        pop de
_:
        cp kYEqu
        jr nz, _
        corelib(launchCastle)
_:

        cp kGraph
        jr nz, _
        corelib(launchThreadList)
_:
        cp kZoom
        jr nz, _
        ld c, 40
        kld(hl, menu)
        corelib(showMenu)
        cp 0xFF
        jr z, .cancel
        kld((numberBase), a)
.cancel:
        kcall(drawScreen)
_:

        cp k0
        jr nz, _
        ld a, 0
        kcall(updateNumber)
_:
    
        cp k1
        jr nz, _
        ld a, 1
        kcall(updateNumber)
_:
    
        cp k2
        jr nz, _
        ld a, 2
        kcall(updateNumber)
_:
    
        cp k3
        jr nz, _
        ld a, 3
        kcall(updateNumber)
_:
    
        cp k4
        jr nz, _
        ld a, 4
        kcall(updateNumber)
_:
    
        cp k5
        jr nz, _
        ld a, 5
        kcall(updateNumber)
_:
    
        cp k6
        jr nz, _
        ld a, 6
        kcall(updateNumber)
_:
    
        cp k7
        jr nz, _
        ld a, 7
        kcall(updateNumber)
_:
    
        cp k8
        jr nz, _
        ld a, 8
        kcall(updateNumber)
_:
    
        cp k9
        jr nz, _
        ld a, 9
        kcall(updateNumber)
_:

    pop af
    ret

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
upperWord:
    .dw 0
lowerWord:
    .dw 0
digits:
    .db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
