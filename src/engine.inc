;; -*- mode: rgbds; -*-

wait_vblank : MACRO
; Wait till the LCD is past VBlank
.waitVBlank\@
    ld a, [rLY]
    cp SCRN_Y
    jr c, .waitVBlank\@
ENDM

stall_cyc : MACRO
    push af
    ld a, \1
.stall\@
    dec a
    jr nz, .stall\@
    pop af
ENDM
