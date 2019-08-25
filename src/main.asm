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
    call TurnOffLCD

    ; Prepare VRAM
    call CopyFont
    call CopyText

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

TurnOffLCD:
    xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
    ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.
    ret

CopyText:
    ld hl, $9800 + 2
    ld de, HelloWorldStr
    ld bc, HelloWorldStrEnd - HelloWorldStr
    call MemCopy
    ret

CopyFont:
    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
    call MemCopy
    ret

MemCopy:
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de ; Move to next byte
    dec bc ; Decrement count
    ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, MemCopy
    ret

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
    db "GENESIS HOODLUM"
HelloWorldStrEnd: