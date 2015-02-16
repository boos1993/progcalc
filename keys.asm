
checkKeys:
    push af

        ;cp kClear
        cp kMode
        jr nz, _
        push de
        push hl
        push af
            ld de, 0

            kld(hl, (lowerWord))
            pcall(cpHLDE)
            jr nz, .notZeroClear
            
            kld(hl, (upperWord))
            pcall(cpHLDE)
            jr nz, .notZeroClear

            ld a, 0
            kld((operator), a)
 
            ld hl, 0
            kld((oldUpperWord), hl)
            kld((oldLowerWord), hl)

            jr .endClear
.notZeroClear:    
        ld hl, 0x0000
            kld((upperWord), hl)
            kld((lowerWord), hl)
            ld a, 0
.endClear:
        pop af
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
        cp kRight
        jr nz, _
        kcall(calculate)
        kcall(mvNewToOld)
        push af
            ld a, 1
            kld((operator), a)
        pop af
_:

        cp kMinus
        cp kLeft
        jr nz, _
        kcall(calculate)
        kcall(mvNewToOld)
        push af
            ld a, 2
            kld((operator), a)
        pop af
_:

        cp kMul
        ;cp kRight
        jr nz, _
        kcall(calculate)
        kcall(mvNewToOld)
        push af
            ld a, 3
            kld((operator), a)
        pop af
_:

        cp kDiv
        ;cp kLeft
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

