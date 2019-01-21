;; -*- mode: rgbds; -*-
INCLUDE "hardware.inc"
INCLUDE "engine.inc"

SECTION "engine",ROM0
loadPal::
;; Input: HL - Source Address of palette colors
;;        A  - Destination palette index
    push af
    push bc
    push hl
    set 7, a
    ld [rBCPS], a

    ld b, 8
.palLoop
    ld a, [hli]
    ld [rBCPD], a
    dec b
    jr nz, .palLoop

    pop hl
    pop bc
    pop af
    ret
