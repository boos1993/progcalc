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
        cp 5
        kjp(z, .mod)
        cp 6
        kjp(z, .lsh)
        cp 7
        kjp(z, .rsh)
        cp 8
        kjp(z, .or)
        cp 9
        kjp(z, .and)
        cp 10
        kjp(z, .xor)
        cp 11
        kjp(z, .not)


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

.mod:
        ;Modulo [HL = Remainder of ACIX / DE]
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
            kld((lowerWord), hl)
            ld hl, 0
            kld((upperWord), hl)
        pop hl
        pop de
        pop ix
        pop bc
        pop af
        kjp(.endOP)

.lsh:
        ;Left Shift
        push hl
        push de
        push af
        push bc
            kld(hl, (lowerWord))
            ld a, l
            and 63    ;Mask off the upper 2 bits
            cp 0
            jr z, .cancelShiftLeft
            ld b, a
.shiftLoop:
            ld d, 0
            ld e, 0
            kld(hl, (oldLowerWord))

            ld a, l
            rl a
            ld l, a
            ld a, h
            rl a
            ld h, a

            ld a, 0
            jr nc, _
            ld a, 1
_:

            add hl, de
            kld((oldLowerWord), hl)


            ld d, 0
            ld e, a
            kld(hl, (oldUpperWord))

            ld a, l
            rl a
            ld l, a
            ld a, h
            rl a
            ld h, a

            add hl, de
            kld((oldUpperWord), hl)

            djnz .shiftLoop
.cancelShiftLeft:
            kld(hl, (oldUpperWord))
            kld((upperWord), hl)
            kld(hl, (oldLowerWord))
            kld((lowerWord), hl)
        pop bc
        pop af
        pop de
        pop hl

        kjp(.endOP)

.rsh:
        ;Right Shift

        push hl
        push de
        push af
        push bc
            kld(hl, (lowerWord))
            ld a, l
            and 63    ;Mask off the upper 2 bits
            cp 0
            jr z, .cancelShiftRight
            ld b, a
.shiftRightLoop:
            ld d, 0
            ld e, 0
            kld(hl, (oldUpperWord))

            ld a, h
            rr a
            ld h, a
            ld a, l
            rr a
            ld l, a

            ld a, 0
            jr nc, _
            ld a, 128
_:

            add hl, de
            kld((oldUpperWord), hl)


            ld d, a
            ld e, 0
            kld(hl, (oldLowerWord))

            ld a, h
            rr a
            ld h, a
            ld a, l
            rr a
            ld l, a

            add hl, de
            kld((oldLowerWord), hl)

            djnz .shiftRightLoop
.cancelShiftRight:
            kld(hl, (oldUpperWord))
            kld((upperWord), hl)
            kld(hl, (oldLowerWord))
            kld((lowerWord), hl)
        pop bc
        pop af
        pop de
        pop hl

        kjp(.endOP)

.or:
        ;OR [32bit = 32bit or 32bit]
        push hl
        push af
        push bc

            ;UpperWord
            kld(hl, (oldUpperWord))
            ld b, h
            ld c, l
            kld(hl, (upperWord))
            ld a, b
            or h
            ld h, a
            ld a, c
            or l
            ld l, a
            kld((upperWord), hl)

            ;LowerWord
            kld(hl, (oldLowerWord))
            ld b, h
            ld c, l
            kld(hl, (lowerWord))
            ld a, b
            or h
            ld h, a
            ld a, c
            or l
            ld l, a
            kld((lowerWord), hl)

        pop bc
        pop af
        pop hl


        kjp(.endOP)

.and:
        ;AND [32bit = 32bit and 32bit]
        push hl
        push af
        push bc

            ;UpperWord
            kld(hl, (oldUpperWord))
            ld b, h
            ld c, l
            kld(hl, (upperWord))
            ld a, b
            and h
            ld h, a
            ld a, c
            and l
            ld l, a
            kld((upperWord), hl)

            ;LowerWord
            kld(hl, (oldLowerWord))
            ld b, h
            ld c, l
            kld(hl, (lowerWord))
            ld a, b
            and h
            ld h, a
            ld a, c
            and l
            ld l, a
            kld((lowerWord), hl)

        pop bc
        pop af
        pop hl
        kjp(.endOP)

.xor:
        ;XOR [32bit = 32bit xor 32bit]
        push hl
        push af
        push bc

            ;UpperWord
            kld(hl, (oldUpperWord))
            ld b, h
            ld c, l
            kld(hl, (upperWord))
            ld a, b
            xor h
            ld h, a
            ld a, c
            xor l
            ld l, a
            kld((upperWord), hl)

            ;LowerWord
            kld(hl, (oldLowerWord))
            ld b, h
            ld c, l
            kld(hl, (lowerWord))
            ld a, b
            xor h
            ld h, a
            ld a, c
            xor l
            ld l, a
            kld((lowerWord), hl)

        pop bc
        pop af
        pop hl
        kjp(.endOP)

.not:
        ;NOT
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
