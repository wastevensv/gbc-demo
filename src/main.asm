;; -*- mode: rgbds; -*-
INCLUDE "hardware.inc"
INCLUDE "engine.inc"

; rst vectors go unused
SECTION "rst00",ROM0[0]
    ret

SECTION "rst08",ROM0[8]
    ret

SECTION "rst10",ROM0[$10]
    ret

SECTION "rst18",ROM0[$18]
    ret

SECTION "rst20",ROM0[$20]
    ret

SECTION "rst30",ROM0[$30]
    ret

SECTION "rst38",ROM0[$38]
    ret

SECTION "vblank",ROM0[$40]
    reti
SECTION "lcdc",ROM0[$48]
    reti
SECTION "timer",ROM0[$50]
    reti
SECTION "serial",ROM0[$58]
    reti
SECTION "joypad",ROM0[$60]
    reti

SECTION "bank0",ROM0[$61]

SECTION "romheader",ROM0[$100]
    nop
    jp _start

SECTION "start",ROM0[$150]

_start:
    nop
    di
    ld sp, $fffe
    jp main

SECTION "text",ROM0
main:
; Reset pallete
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a

; Setup Pallette
    ld de, PalA
    ld a, $00
    call loadPal

; Reset scrolling
    ld a, 0
    ld [rSCX], a
    ld [rSCY], a

; Turn off sound
    ld [rNR52], a

; Wait till the LCD is past VBlank
    wait_vblank

    ld hl, _VRAM	; Font goes at start of VRAM
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
.copyFont
    ld a, [de]    ; Grab 1 byte from the source
    ld [hli], a   ; Place it at the destination, incrementing hl
    inc de	  ; Move to next byte
    dec bc	  ; Decrement count
    ld a, b	  ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, .copyFont

    ld hl, _SCRN0+$21 ; This will print the string at the top-left corner of the screen
    ld de, HelloWorldStr
.copyString
; Stall till A pressed
    ld a, %00010000
    ld [rP1], a
.aPress
    ld a, [rP1]
    stall_cyc 15
    bit 0, a
    jp z, .aPress

; Stall till A released
.aRelease
    ld a, [rP1]
    stall_cyc 15
    bit 0, a
    jp nz, .aRelease

; Print Character
    ld a, [de]
    ld [hli], a
    inc de

    and a              ; Check if the byte we just copied is zero
    jr nz, .copyString ; Continue if it's not

    halt

SECTION "tiles", ROM0
FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "strings", ROM0
HelloWorldStr:
    db "Hello World!", 0

SECTION "palette",ROM0
PalA:
    dw %0111111111111111, %0000000111100000, \
       %0000000000001111, %0011110000000000  ; WGBR
