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





        ;Skip Draw oldNumber and operator if no operator
        kld(a, (operator))
        cp 0
        kjp(z, .drawNewNumber)


;----------OldNumber-----------
        ld d, 4
        ld e, 30
        
        kld(a, (numberBase))
        cp 0
        jr z, .oldDecimalDraw
        cp 1
        jr z, .oldHexDraw
        cp 2
        jr z, .oldBinaryDraw

.oldBinaryDraw:  
        ;Draw Binary
        kld(hl, (oldUpperWord))
        ;pcall(drawHexHL)
        kld(hl, (oldLowerWord))
        ;pcall(drawHexHL)
        jr .oldEndDraw
.oldHexDraw:  
        ;Draw Hex
        kld(hl, (oldUpperWord))
        pcall(drawHexHL)
        kld(hl, (oldLowerWord))
        pcall(drawHexHL)
        jr .oldEndDraw
.oldDecimalDraw:     
        ;Draw Decimal
        kld(hl, (oldUpperWord))
        ld a, h
        ld c, l
        kld(ix, (oldLowerWord))
        pcall(drawDecACIX)
        jr .oldEndDraw
.oldEndDraw:

;----------Operator -----------
        ld d, 4
        ld e, 40
        
        kld(a, (operator))
        cp 0
        jr z, .drawNewNumber
        cp 1
        jr z, .drawPlus
        cp 2
        jr z, .drawMinus
        cp 3
        jr z, .drawMul
        cp 4
        jr z, .drawDiv


.drawPlus:
        ld a, '+'
        pcall(drawChar)
        jr .drawNewNumber

.drawMinus:
        ld a, '-'
        pcall(drawChar)
        jr .drawNewNumber

.drawMul:
        ld a, '*'
        pcall(drawChar)
        jr .drawNewNumber

.drawDiv:
        ld a, '/'
        pcall(drawChar)
        jr .drawNewNumber



;----------NewNumber-----------
.drawNewNumber:
        ld d, 4
        ld e, 50

        kld(a, (numberBase))
        cp 0
        jr z, .decimalDraw
        cp 1
        jr z, .hexDraw
        cp 2
        jr z, .binaryDraw

.binaryDraw:  
        ;Draw Binary
        kld(hl, (upperWord))
        ;pcall(drawHexHL)
        kld(hl, (lowerWord))
        ;pcall(drawHexHL)
        jr .endDraw
.hexDraw:  
        ;Draw Hex
        kld(hl, (upperWord))
        pcall(drawHexHL)
        kld(hl, (lowerWord))
        pcall(drawHexHL)
        jr .endDraw
.decimalDraw:     
        ;Draw Decimal
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

