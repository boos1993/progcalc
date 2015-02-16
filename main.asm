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
    cp kUp
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


drawScreen:
    pcall(clearBuffer)
    push af
    push de
    push hl
    push ix


;----------Window-----------
        kld(hl, windowTitle)
        ld a, 0x04
        corelib(drawWindow)



;----------Binary-----------
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




;----------NewNumber-----------
        kld(a, (numberBase))
        cp 0
        jr z, .decimalDraw
        cp 1
        jr z, .hexDraw
        cp 2
        jr z, .binaryDraw

.binaryDraw:  
        ;Draw Binary
        ld d, 4
        ld e, 40
        kld(hl, (upperWord))
        ;pcall(drawHexHL)
        kld(hl, (lowerWord))
        ;pcall(drawHexHL)
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
        kld(ix, (lowerWord))
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

;; calculate
;;  Calculates oldNumber (operator) newNumber
;;  Stores the result in newNumber and clears the operator
;; Inputs:
calculate:
    push af
    push hl
        kld(a, (operator))
        cp 0
        kjp(z, .noOP)
        cp 1
        kjp(z, .add)
        cp 2
        kjp(z, .sub)
        cp 3
        kjp(z, .mul)
        cp 4
        kjp(z, .div)

.noOP:
        ;No Operator
        kjp(.endOP)

.add:
        ;Addition [ACIX = ACIX + DE]
        push af
        push bc
        push ix
        push de
        push hl
            ;Load Old Number
            kld(hl, (oldUpperWord))
            ld a, h
            ld c, l
            kld(ix, (oldLowerWord))
            
            ;Load New Number
            kld(hl, (lowerWord))
            ld d, h
            ld e, l
            
            pcall(add16To32)
            
            ;Store ACIX into newNumber
            ld h, a
            ld l, c
            kld((upperWord), hl)
            kld((lowerWord), ix)
        pop hl
        pop de
        pop ix
        pop bc
        pop af
        kjp(.endOP)

.sub:
        ;Subtraction [ACIX = ACIX - DE]
        push af
        push bc
        push ix
        push de
        push hl
            ;Load Old Number
            kld(hl, (oldUpperWord))
            ld a, h
            ld c, l
            kld(ix, (oldLowerWord))
            
            ;Load New Number
            kld(hl, (lowerWord))
            ld d, h
            ld e, l
            
            pcall(sub16From32)
            
            ;Store ACIX into newNumber
            ld h, a
            ld l, c
            kld((upperWord), hl)
            kld((lowerWord), ix)
        pop hl
        pop de
        pop ix
        pop bc
        pop af
        kjp(.endOP)

.mul:
        ;Multiplication [DEHL = DEHL * A]
        push af
        push de
        push hl
            ;Load Old Number
            kld(hl, (oldUpperWord))
            ld d, h
            ld e, l
            kld(hl, (oldLowerWord))
            
            ;Load New Number
            push hl
                kld(hl, (lowerWord))
                ld a, l
            pop hl

            pcall(mul32By8)
            
            ;Store DEHL into newNumber
            kld((lowerWord), hl)
            ld h, d
            ld l, e
            kld((upperWord), hl)
        pop hl
        pop de
        pop af
        kjp(.endOP)

.div:
        ;Division [ACIX = ACIX / DE]
        push af
        push bc
        push ix
        push de
        push hl
            ;Load Old Number
            kld(hl, (oldUpperWord))
            ld a, h
            ld c, l
            kld(ix, (oldLowerWord))
            
            ;Load New Number
            push hl
                kld(hl, (lowerWord))
                ld d, h
                ld e, l
            pop hl

            pcall(div32By16)
            
            ;Store ACIX into newNumber
            ld h, a
            ld l, c
            kld((upperWord), hl)
            kld((lowerWord), ix)
        pop hl
        pop de
        pop ix
        pop bc
        pop af
        kjp(.endOP)

.endOP:
        ;Clear Operator
        ld a, 0
        kld((operator), a)
        
        ;Clear Old Number
        ld hl, 0
        kld((oldUpperWord), hl)
        kld((oldLowerWord), hl)


    pop hl
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


checkKeys:
    push af

        cp kClear
        jr nz, _
        push de
        push hl
            ;TODO: if newNumber is zero...then clear operator and oldNumber...else clear newNumber
            ;ld de, 0x0000
            ld hl, 0x0000
            kld((upperWord), hl)
            kld((lowerWord), hl)
            ld a, 0
           ; kcall(addDigit)
           ; kcall(drawScreen)
        pop hl
        pop de
_:

        cp kDown
        jr nz, _
            kcall(removeDigit)
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
_:


;----------Operators-----------
        cp kEnter
        jr nz, _
        kcall(calculate)
_:

        cp kPlus
        ;cp kRight
        jr nz, _
        kcall(calculate)
        kcall(mvNewToOld)
        push af
            ld a, 1
            kld((operator), a)
        pop af
_:

        cp kMinus
        ;cp kLeft
        jr nz, _
        kcall(calculate)
        kcall(mvNewToOld)
        push af
            ld a, 2
            kld((operator), a)
        pop af
_:

        ;cp kMul
        cp kRight
        jr nz, _
        kcall(calculate)
        kcall(mvNewToOld)
        push af
            ld a, 3
            kld((operator), a)
        pop af
_:

        ;cp kDiv
        cp kLeft
        jr nz, _
        kcall(calculate)
        kcall(mvNewToOld)
        push af
            ld a, 4
            kld((operator), a)
        pop af
_:


;------------Digits------------
        cp k0
        jr nz, _
        ld a, 0
        kcall(addDigit)
_:
        cp k1
        jr nz, _
        ld a, 1
        kcall(addDigit)
_:
        push bc
            ld b, a
            kld(a, (numberBase))
            cp 2
            ld a, b
        pop bc
        kjp(z, .endKeys)
        
        cp k2
        jr nz, _
        ld a, 2
        kcall(addDigit)
_:
    
        cp k3
        jr nz, _
        ld a, 3
        kcall(addDigit)
_:
    
        cp k4
        jr nz, _
        ld a, 4
        kcall(addDigit)
_:
    
        cp k5
        jr nz, _
        ld a, 5
        kcall(addDigit)
_:
    
        cp k6
        jr nz, _
        ld a, 6
        kcall(addDigit)
_:
    
        cp k7
        jr nz, _
        ld a, 7
        kcall(addDigit)
_:
    
        cp k8
        jr nz, _
        ld a, 8
        kcall(addDigit)
_:
    
        cp k9
        jr nz, _
        ld a, 9
        kcall(addDigit)
_:
        push bc
            ld b, a
            kld(a, (numberBase))
            cp 0
            ld a, b
        pop bc
        kjp(z, .endKeys)


        ;HEXADECIMAL KEYS
        cp kA
        jr nz, _
        ld a, 0x0A
        kcall(addDigit)
_:
    
        cp kB
        jr nz, _
        ld a, 0x0B
        kcall(addDigit)
_:
    
        cp kC
        jr nz, _
        ld a, 0x0C
        kcall(addDigit)
_:
    
        cp kD
        jr nz, _
        ld a, 0x0D
        kcall(addDigit)
_:
    
        cp kE
        jr nz, _
        ld a, 0x0E
        kcall(addDigit)
_:

        cp kF
        jr nz, _
        ld a, 0x0F
        kcall(addDigit)
_:

.endKeys:

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

