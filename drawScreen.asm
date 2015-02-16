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

