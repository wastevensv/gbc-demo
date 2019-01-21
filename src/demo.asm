;; -*- mode: rgbds; -*-
INCLUDE "hardware.inc"

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
    jp Start

SECTION "start",ROM0[$150]

Start:
    nop
    di
    ld sp, $fffe
    ld a, $42

init:
; Reset pallete
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a

; Setup Pallette
    ld a, %10000000
    ld [$ff68], a

    ld bc, %0111111111111111  ; white
    ld a, c
    ld [$ff69], a
    ld a, b
    ld [$ff69], a
    ld bc, %0000001111100000  ; green
    ld a, c
    ld [$ff69], a
    ld a, b
    ld [$ff69], a
    ld bc, %0000000000011111  ; red
    ld a, c
    ld [$ff69], a
    ld a, b
    ld [$ff69], a
    ld bc, %0111110000000000  ; blue
    ld a, c
    ld [$ff69], a
    ld a, b
    ld [$ff69], a

; Reset scrolling
    ld a, 0
    ld [rSCX], a
    ld [rSCY], a

; Turn off sound
    ld [rNR52], a

; Wait till the LCD is past VBlank
.waitVBlank:
    ld a, [rLY]
    cp SCRN_Y
    jr c, .waitVBlank

    ld hl, _VRAM
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
.copyFont
    ld a, [de]    ; Grab 1 byte from the source
    ld [hli], a   ; Place it at the destination, incrementing hl
    inc de    	  ; Move to next byte
    dec bc 	  ; Decrement count
    ld a, b  	  ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, .copyFont

    ld hl, _SCRN0+1 ; This will print the string at the top-left corner of the screen
    ld de, HelloWorldStr
.copyString
    ld a, [de]
    ld [hli], a
    inc de
    and a              ; Check if the byte we just copied is zero
    jr nz, .copyString ; Continue if it's not

    halt

SECTION "font", ROM0
FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "strings", ROM0

HelloWorldStr:
    db "Hello World!", 0
