;; -*- mode: rgbds; -*-

; Wait till the LCD is past VBlank
wait_vblank : MACRO
    push af
.waitVBlank\@
    ld a, [rLY]
    cp SCRN_Y
    jr c, .waitVBlank\@
    pop af
ENDM

; Usage: stall_cyc n
; Stall for n cycles.
stall_cyc : MACRO
    push af
    ld a, \1
.stall\@
    dec a
    jr nz, .stall\@
    pop af
ENDM

; Usage: stall_key b
; b is bit number to check
; Wait on key press and release.
; Only uses Start (b=3), Sel, B, A (b=0)
stall_key : MACRO
    ld a, %00010000
    ld [rP1], a
; Stall till A pressed
.aPress
    ld a, [rP1]
    stall_cyc 15
    bit \1, a
    jp z, .aPress

; Stall till A released
.aRelease
    ld a, [rP1]
    stall_cyc 15
    bit \1, a
    jp nz, .aRelease
ENDM
