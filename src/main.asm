;; -*- mode: rgbds; -*-
INCLUDE "hardware.inc"
INCLUDE "engine.inc"

; rst vectors are currently unused
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

SECTION "romheader",ROM0[$100]
    nop
    jp _start

SECTION "start",ROM0[$150]

_start:
    nop
    di
    ld sp, $fffe

; Disable LCD during VRAM  writes.
    ld a, [rLCDC]
    res 7, a
    ld [rLCDC], a

; Reset pallete
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a

; Setup Pallette
    ld hl, BGPal
    ld a, $00
    call loadBGPal

; Setup Pallette
    ld hl, CoinPal
    ld a, $00
    call loadOBJPal

; Reset scrolling
    ld a, 0
    ld [rSCX], a
    ld [rSCY], a

; Turn off sound
    ld [rNR52], a

    ld hl, TileStart
    ld de, _VRAM+$200  ; Font goes at start of VRAM
    ld bc, TileEnd - TileStart
    call memcpy

    ld a, [rLCDC]
    set 7, a
    ld [rLCDC], a
; Reenable LCD after VRAM writes.

    ld a,$02
    ld [rROMB0],a       ; Switch to Bank 2
    jp main


SECTION "main",ROMX,BANK[2]
main:
; This will print the string at the top-left corner of the screen
    ld hl, _SCRN0+$21
    ld de, HelloWorldStr
.copyString
    wait_key PADB_A
    wait_vblank
; Print Character
    ld a, [de]
    ld [hli], a
    inc de

    and a              ; Check for null terminator
    jr nz, .copyString ; Continue if a is not 0

    ld a, [rLCDC]
    set 1, a
    ld [rLCDC], a

    ld a, $10
    ld [_OAMRAM+1], a
    ld a, $81
    ld [_OAMRAM+2], a

    
.moveRestart
    ld a, $20
.moveDown
    ld [_OAMRAM+0], a
    inc a
    wait_div $02,$F0
    wait_vblank
    cp $40
    jp nz, .moveDown
.moveUp
    ld [_OAMRAM+0], a
    dec a
    wait_div $02,$F0
    wait_vblank
    cp $20
    jp nz, .moveUp
    jp z, .moveRestart

    halt

SECTION "tiles", ROMX,BANK[1]
TileStart:

FontTiles:
INCBIN "font.bin"
FontTilesEnd: ; 0x20-0x7F

TestTile:
INCBIN "tile.bin"
TestTileEnd: ; 0x80

CoinSprite:
INCBIN "coin.bin"
CoinSpriteEnd: ; 0x81

TileEnd:

SECTION "palette",ROMX,BANK[1]
BGPal:
    dw %0111111111111111, %0000001111100000, \
       %0000000000011111, %0111110000000000

BGPalAlt:
    dw %0000000000011111, %0000001111100000, \
       %0111111111111111, %0111110000000000

CoinPal:
    dw %0111111111111111, %0001110110101110, \
       %0011010111001111, %0010100011101111

SECTION "strings", ROMX,BANK[2]
HelloWorldStr:
    db "Hello World!", $80, 0
