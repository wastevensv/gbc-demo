;; -*- mode: rgbds; -*-
INCLUDE "hardware.inc"
INCLUDE "engine.inc"

SECTION "engine",ROM0
loadPal::
;; Input: DE - Source Address of palette colors
;;        A  - Destination palette index
    push af
    push bc
    push de
    set 7, a
    ld [rBCPS], a

    ld b, 8
.palLoop
    ld a, [de]
    inc de
    ld [rBCPD], a
    dec b
    ld a, b
    and a
    jr nz, .palLoop

    pop de
    pop bc
    pop af
    ret
