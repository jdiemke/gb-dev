SECTION "HEADER", ROM0[$104]

; rgbfix will patch this area with the
; Nintendo logo and header data including checksums

REPT $150 - $104
    db 0
ENDR
