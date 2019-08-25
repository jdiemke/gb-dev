INCLUDE "/include/gb_hardware.inc"
INCLUDE "/include/entry_point.inc"
INCLUDE "/include/header.inc"

SECTION "Main", ROM0

Main:
    ; SETUP PROCESS
    call TurnOffLCD
    call SetupDemo
    call TurnOnLCD

    ; MAIN LOOP
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

TurnOnLCD:
    ld a, %10000001
    ld [rLCDC], a
    ret

SetupDemo:
    call CopyFont
    call CopyText
    call InitDisplayReg
    call InitScreenPos
    call ShutSoundDown
    ret

TurnOffLCD:
    call WaitVBlank
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