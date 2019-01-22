;; -*- mode: rgbds; -*-

wait_vblank : MACRO
; Wait till the LCD is past VBlank
    push af
.waitVBlank\@
    ld a, [rLY]
    cp SCRN_Y
    jr c, .waitVBlank\@
    pop af
ENDM

stall_cyc : MACRO
    push af
    ld a, \1
.stall\@
    dec a
    jr nz, .stall\@
    pop af
ENDM
