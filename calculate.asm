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
        kjp(.endOP)

.rsh:
        ;Right Shift
        kjp(.endOP)

.or:
        ;OR
        kjp(.endOP)

.and:
        ;AND
        kjp(.endOP)

.xor:
        ;XOR
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
