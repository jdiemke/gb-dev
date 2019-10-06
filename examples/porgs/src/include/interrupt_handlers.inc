; Interrupt Handlers

SECTION "Vertical Blank Interrupt", ROM0[$0040]
    inc b

    reti

SECTION	"LCD Status Interrupt", ROM0[$0048]
    call Wobble
    reti

SECTION	"Timer Interrupt", ROM0[$0050]
    reti

SECTION	"Serial Interrupt", ROM0[$0058]
    reti

SECTION	"Joypad Interrupt", ROM0[$0060]
    reti