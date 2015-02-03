#include "kernel.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 20
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "progcalc", 0
start:
    ; This is an example program, replace it with your own!
    
    ; Get a lock on the devices we intend to use
    pcall(getLcdLock)
    pcall(getKeypadLock)

    ; Allocate and clear a buffer to store the contents of the screen
    pcall(allocScreenBuffer)
    pcall(clearBuffer)

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

checkKeys:
    push af

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

        cp kMode
        jr nz, _
        push de
        push hl
            ld de, 0
            ld hl, 0
            kld((leftNumber), de)
            kld((rightNumber), hl)
        pop hl
        pop de
        _:


    pop af
    ret

updateNumber:
    push af
    push de
        ;Shift over one decimal place
        kld(de, (leftNumber))
        kld(hl, (rightNumber))
        push af
            ld a, 0x0A
            pcall(mul32By8)
        pop af
        kld((leftNumber), de)
        kld((rightNumber), hl)       


        ;add the new number
        ld e, a
        ld d, 0
        kld(hl, (leftNumber))
        ld a, h
        ld c, l
        kld(ix, (rightNumber))
        pcall(add16To32)
        ld h, a
        ld l, c
        kld((leftNumber), hl)
        kld((rightNumber), ix)

    pop de
    pop af
    ret

drawScreen:
    pcall(clearBuffer)
    
    ld d, 4
    ld e, 0
    kld(hl, (leftNumber))
    kcall(drawBits)

    push af
        ld a, d
        add a, 9
        ld d, a
    pop af
    ld h, l
    kcall(drawBits)

    ld d, 4
    ld e, 10
    kld(hl, (rightNumber))
    kcall(drawBits)

    push af
        ld a, d
        add a, 9
        ld d, a
    pop af
    ld h, l
    kcall(drawBits)

    ld d, 0
    ld e, 30
    kld(hl, (leftNumber))
    pcall(drawHexHL)
    kld(hl, (rightNumber))
    pcall(drawHexHL)
    ret

drawBits:
    push af
    
    ld a, 8

    moreBits:
    dec a

    bit 7, h
    jr nz, one

    push af
        ld a, '0'
        pcall(drawChar)
    pop af
    jr _

    one:
    push af
        ld a, '1'
        pcall(drawChar)
    pop af

    _:
    
    inc d
    SLA h


    cp 0

    jr nz, moreBits

    pop af
    ret

message:
    .db "Programmer Calc v0.1", 0
leftNumber:
    .dw 0
rightNumber:
    .dw 0
digits:
    .db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
