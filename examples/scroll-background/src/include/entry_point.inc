;
; Code Execution always starts at address $100 in ROM
;

SECTION "ENTRY_POINT", ROM0[$100]

EntryPoint:
    nop
    jp Main
