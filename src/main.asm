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
    ld hl, PalA
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
    ld bc, TestTilesEnd - FontTiles
    call memcpy

; This will print the string at the top-left corner of the screen
    ld hl, _SCRN0+$21
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
TileStart:
FontTiles:
INCBIN "font.bin"
FontTilesEnd:

TEST_TILE EQU (FontTilesEnd - FontTiles) >> 4
TestTiles:
INCBIN "tile.bin"
TestTilesEnd:

SECTION "strings", ROM0
HelloWorldStr:
    db "Hello World!", TEST_TILE, 0

SECTION "palette",ROM0
PalA:
    dw %0111111111111111, %0000001111100000, \
       %0000000000011111, %0111110000000000  ; WGBR
