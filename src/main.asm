;INCLUDE "/include/gb_hardware.inc"
INCLUDE "/include/hardware.inc"
INCLUDE "/include/entry_point.inc"
INCLUDE "/include/header.inc"

SECTION "Main", ROM0

Main:
    ; SETUP PROCESS
    call TurnOffLCD
    call SetupDemo
    call TurnOnLCD

    call InitPlayer
   
    ; MAIN LOOP
    ld b, -50
    ld c, 0
.main_loop
    call WaitVBlank
    call PlayMusic
    inc c
    ld a, c
    cp a, 14
    jp nz, .main_loop



    ld c, 0
    inc b
    ld a, b
    ld [rSCY], a
    jr .main_loop

; FUNCTIONS

InitPlayer:
    ; Init Speed
    ld HL, speed
    ld [HL], 100

    ; Init Ticks
    ld HL, ticks
    ld [HL], 0

    ret

PlayMusic:
    push bc

    ld hl, ticks
    ld b, [hl]
    ld a, [speed]
    inc b
    ld [hl], b

    cp	a,b
	jr	z,.dontexit

    pop bc
    ret

.dontexit:
    ; Reset Ticks
    ld [hl], 0
    ; TODO: load next pattern and play on channels
    ; sound
    ld a, $4F
    ld [rNR10], a

    ld a, $96
    ld [rNR11], a

    ld a, $B7
    ld [rNR12], a

    ld a, $BB
    ld [rNR13], a

    ld a, $85
    ld [rNR14], a

    pop bc
    ret

TurnOnLCD:
    ld a, %10000001
    ld [rLCDC], a
    ret

SetupDemo:
    ;call CopyFont
    ;call CopyText
    ld hl, $9000
    ld de, TileData
    ld bc, 128 * 16 ; 128 is number of tiles
    call MemCopy

    call MemCopy2

    call InitDisplayReg
    call InitScreenPos
    ;call ShutSoundDown
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

MemCopy2:
    ld hl, $9800
    ld de, MapData
    ld a, 18
.loop:
    ld bc, 20
    push af
.row:
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de ; Move to next byte
    dec bc ; Decrement count
    ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, .row
    ld bc, 12
    add hl, bc
    pop af
    dec a

    jr nz, .loop
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

SECTION "Music Player", wram0

speed:
    DS 1

ticks:
    DS 1

SECTION "Font", ROM0

FontTiles:
INCBIN "assets/font.chr"
FontTilesEnd:

SECTION "Hello World string", ROM0

HelloWorldStr:
    db "GENESIS HOODLUM"
HelloWorldStrEnd:

SECTION "LOGO", ROM0

INCLUDE "./logo_tiles.Z80"
INCLUDE "./logo_tiles_map.Z80"