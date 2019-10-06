INCLUDE "/include/hardware.inc"

INCLUDE "/include/rst_handlers.inc"
INCLUDE "/include/interrupt_handlers.inc"
INCLUDE "/include/entry_point.inc"
INCLUDE "/include/header.inc"

SECTION "Main", ROM0[$0150]

Main:
    call DisableInterrupts

    call TurnOffLCD
    call SetupDemo
    call TurnOnLCD
   
    call EnableVBLInterrupt
    call EnableInterrupts
    ;call EnableHBlankInterrupt

    ld b, 0
.main_loop
    REPT 7
        call EnterLowPowerMode
    ENDR
    inc b
    call DrawSprite
    jr .main_loop

; FUNCTIONS

SetPalette:
    ld [rBGP], a
    ret

EnableHBlankInterrupt:
    ld      a, STATF_MODE00 ; enable hblank interrupts of LCD interrups
    ld      [rSTAT], a
    ret

; https://gbdev.gg8.se/wiki/articles/Reducing_Power_Consumption
; https://www.reddit.com/r/EmuDev/comments/5bfb2t/a_subtlety_about_the_gameboy_z80_halt_instruction/
; http://www.devrs.com/gb/files/gbspec.txt
EnterLowPowerMode:
    halt
    nop
    ret

DrawSprite:

    ld de, _OAMRAM
    ; y-coord
    ld a, 16 + 32
    ld [de], a
    ld de, _OAMRAM+1
    ; x-coord
    ld a, b
    ld [de], a
    ld de, _OAMRAM+2
    ; tile index
    ld a, 26
    ld [de], a
    ld de, _OAMRAM+3
    ; attributes, including palette, which are all zero
    ld a, %00000000
    ld [de], a
    ld de, _OAMRAM+4

    ; y-coord
    ld a, 16 + 32
    ld [de], a
    ld de, _OAMRAM+5
    ; x-coord
    ld a, b
    add a, 8
    ld [de], a
    ld de, _OAMRAM+6
    ; tile index
    ld a, 26+1
    ld [de], a
    ld de, _OAMRAM+7
    ; attributes, including palette, which are all zero
    ld a, %00000000
    ld [de], a
    ld de, _OAMRAM+8

        ; y-coord
    ld a, 16 + 32 + 8
    ld [de], a
    ld de, _OAMRAM+9
    ; x-coord
    ld a, b

    ld [de], a
    ld de, _OAMRAM+10
    ; tile index
    ld a, 26+2
    ld [de], a
    ld de, _OAMRAM+11
    ; attributes, including palette, which are all zero
    ld a, %00000000
    ld [de], a
    ld de, _OAMRAM+12

        ; y-coord
    ld a, 16 + 32 + 8
    ld [de], a
    ld de, _OAMRAM+13
    ; x-coord
    ld a, b
    add a, 8
    ld [de], a
    ld de, _OAMRAM+14
    ; tile index
    ld a, 26+3
    ld [de], a
    ld de, _OAMRAM+15
    ; attributes, including palette, which are all zero
    ld a, %00000000
    ld [de], a
    ld de, _OAMRAM+16

    ret

EnableVBLInterrupt:
    ld      a, IEF_VBLANK; | IEF_LCDC ; enable vblank und LCD interrupts
    ld      [rIE], a
    ret

DisableInterrupts:
    di
    ret

EnableInterrupts:
    ei
    ret

TurnOnLCD:
    ld a, LCDCF_BGON | LCDCF_ON | LCDCF_BG8000 |LCDCF_OBJON
    ld [rLCDC], a
    ret

SetupDemo:
    call ClearOAM

    ; do not overwrite nitendo logo with sprite data
    ld hl, $8000 + 26*8*2
    ld de, TileData2
    ld bc, 4 * 8 * 2 ; 100 is number of tiles
                       ; 8 the number of pixel rows
                       ; 2 the number of bytes per pixel row
    call MemCopy

    ; sprite pal
    ld a, %11100100
    ld [rOBP0], a

    ; nintendo logo black
    ld a, %11101100
    ld [rBGP], a

    call InitScreenPos
    call ShutSoundDown
    ret

ClearOAM:
    ld a, 0
    ld c, 40 * 4
    ld hl, _OAMRAM
loop:
    ld [hl+], a
    dec c
    jr nz, loop
    ret

ClearBG:
    ld a, 5
    ld c, 255
    ld hl, _SCRN0
loop2
    REPT 4
        ld [hl+], a
    ENDR
    dec c

    jr nz, loop2
    ret

TurnOffLCD:
    ; call WaitVBlank
    ld a, IEF_VBLANK
    ld [rIE], a

    halt

    ld a, LCDCF_OFF ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
    ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.
 
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
    ld hl, _SCRN0
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

SECTION "Sprites", ROM0

INCLUDE "./assets/link_sprite.Z80"
