mathSelect:
    kld(a, (operatorList))
    ld c, a     ;array count
    dec a
    ld b, a     ;current indexA

.loop:
    kcall(drawList)
    pcall(flushKeys)
    pcall(waitKey)

    cp kDown
    jr nz, _
    ;Move cursor up
    push af
        ld a, b
        cp 0
        jr z, .atTop
        dec a
        ld b, a
.atTop:
    pop af
_:
    cp kUp
    jr nz, _
    ;Move cursor down
    push af
        ld a, b
        inc a
        cp c
        jr z, .atBottom
        ld b, a
.atBottom:
    pop af
_:
    cp kEnter
    jr nz, _
    ;Select the operator
    ld a, c
    sub b
    add a, 4
    jr .exit
_:
    cp kMode
    jr nz, .loop
    ld a, 0
.exit:
    
    pcall(flushKeys)
    ret

drawList:
    pcall(clearBuffer)

    kld(hl, message)
    ld d, 4
    ld e, 56
    pcall(drawStr)

    ld d, 4
    ld e, 4

    kld(hl, operatorList)
    inc hl
    ld a, b ;load current index into a
    inc a
    push bc
        ld b, c

.drawStrings:
        
        cp b
        jr nz, .notIndex
        push hl
        push bc
        push de
            ld c, 95
            ld b, 6
            ld l, e
            ld e, 0
            pcall(rectOR)            
        pop de
        pop bc
        pop hl
        pcall(drawStrAND)
        jr .moveHL
.notIndex: 

        pcall(drawStr)
.moveHL:
        push bc
            pcall(strlen)
            add hl, bc
            ld b, 4
            pcall(newline)
        pop bc
        inc hl
        djnz .drawStrings
    pop bc

    pcall(fastCopy)
    ret


message:
    .db "Press [MODE] to cancel", 0
operatorList:
    .db 6
    .db "x mod y", 0
    .db "x << y", 0
    .db "x >> y", 0
    .db "x or y", 0
    .db "x and y", 0
    .db "x xor y", 0
 

