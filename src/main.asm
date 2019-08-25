INCLUDE "./hardware.inc"

SECTION "Header", ROM0[$100] ; I'm repeating this line so you know where we are. Don't write it twice!

EntryPoint: ; This is where execution begins
    di ; Disable interrupts. That way we can avoid dealing with them, especially since we didn't talk about them yet :p
    jp Start ; Again, I'm repeating this line, but you shouldn't

REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0

Start:
    ; Turn off the LCD
    call WaitVBlank

    xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
    ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.

    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
.copyFont
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de ; Move to next byte
    dec bc ; Decrement count
    ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, .copyFont
    ld hl, $9802 ; This will print the string at the top-left corner of the screen
    ld de, HelloWorldStr
.copyString
    ld a, [de]
    ld [hli], a
    inc de
    and a ; Check if the byte we just copied is zero
    jr nz, .copyString ; Continue if it's not

    call InitDisplayReg
    call InitScreenPos
    call ShutSoundDown

    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a

    ; Lock up
    ld b, -50
    ld c, 0
.main_loop
    call WaitVBlank
    inc c
    ld a, c
    cp a, 9
    jp nz, .main_loop
    ld c, 0
    inc b
    ld a, b
    ld [rSCY], a
    jr .main_loop

; FUNCTIONS

InitDisplayReg:
    ld a, %11100100
    ld [rBGP], a
    ret
    
ShutSoundDown:
    xor a
    ld [rNR52], a
    ret

InitScreenPos:
    xor a
    ld [rSCY], a
    ld [rSCX], a
    ret

WaitVBlank:
    ld a, [rLY]
    cp 144
    jr nz, WaitVBlank
    ret

SECTION "Font", ROM0

FontTiles:
INCBIN "assets/font.chr"
FontTilesEnd:

SECTION "Hello World string", ROM0

HelloWorldStr:
    db "GENESIS HOODLUM", 0