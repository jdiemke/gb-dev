INCLUDE "/include/hardware.inc"
INCLUDE "/include/entry_point.inc"
INCLUDE "/include/header.inc"

SECTION "VBL interrupt vector", ROM0[$0040]
    inc b
    reti

SECTION	"LCDC", ROM0[$0048]
    call Wobble
    reti

SECTION "Main", ROM0

Main:
    call DisableInterrupts
    call TurnOffLCD
    call SetupDemo
    call TurnOnLCD
   
    call EnableVBLInterrupt
    call EnableInterrupts
    call EnableHBlankInterrupt

    ld b, 0
.main_loop
    call EnterLowPowerMode
    jr .main_loop

; FUNCTIONS

EnableHBlankInterrupt:
    ld      a,%00001000 ; enable hblank interrupts of LCD interrups
    ld      [$ff41], a
    ret

; https://gbdev.gg8.se/wiki/articles/Reducing_Power_Consumption
; https://www.reddit.com/r/EmuDev/comments/5bfb2t/a_subtlety_about_the_gameboy_z80_halt_instruction/
; http://www.devrs.com/gb/files/gbspec.txt
EnterLowPowerMode:
    halt
    nop
    ret

Wobble:
    ld A, [rLY]
    add b
    ld h, Sine >> 8
    ld l, a
    ld a, [hl]
    sub 64
    ld [rSCX], a
    ret

EnableVBLInterrupt:
    ld      a,%00000011 ; enable vblank und LCD interrupts
    ld      [rIE], a
    ret

DisableInterrupts:
    di
    ret

EnableInterrupts:
    ei
    ret

TurnOnLCD:
    ld a, %10000001
    ld [rLCDC], a
    ret

SetupDemo:
    ld hl, $9000
    ld de, TileData
    ld bc, 128 * 16 ; 128 is number of tiles
    call MemCopy

    call MemCopy2

    call InitDisplayReg
    call InitScreenPos
    call ShutSoundDown
    ret

TurnOffLCD:
    call WaitVBlank
    xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
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

SECTION "Sine Table", rom0[$300]

Sine:
ANGLE SET   0.0
      REPT  256
      DB    (MUL(64.0,SIN(ANGLE))+64.0)>>16
ANGLE SET ANGLE+256.0
      ENDR

SECTION "LOGO", ROM0

INCLUDE "./assets/trsi_logo_tiles.Z80"
INCLUDE "./assets/trsi_logo_tiles_map.Z80"
