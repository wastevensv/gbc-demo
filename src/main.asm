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

; Wait till the LCD is past VBlank
    wait_vblank

    ld hl, _VRAM	; Font goes at start of VRAM
    ld de, TileStart
    ld bc, TileEnd - TileStart
    call memcpy

   ld hl, _VRAM+$1000   ; Coin sprite goes at $8800
   ld de, SpriteStart
   ld bc, SpriteEnd - SpriteStart
   call memcpy

   ld a,$02
   ld [rROMB0],a       ; Switch to Bank 2
   jp main


SECTION "main",ROMX,BANK[2]
main:
; This will print the string at the top-left corner of the screen
    ld hl, _SCRN0+$21
    ld de, HelloWorldStr
.copyString
    stall_key PADB_A
; Print Character
    ld a, [de]
    ld [hli], a
    inc de

    and a              ; Check for null terminator
    jr nz, .copyString ; Continue if a is not 0

    halt

SECTION "tiles", ROMX,BANK[1]
TileStart:

FontTiles:
INCBIN "font.bin"
FontTilesEnd:

TestTile:
INCBIN "tile.bin"
TestTileEnd:
TEST_TILE EQU (TestTile - TileStart) >> 4

TileEnd:

SpriteStart:

CoinSprite:
INCBIN "coin.bin"
CoinSpriteEnd:
COIN_SPRITE EQU ((CoinSprite - SpriteStart) >> 4) + $80

SpriteEnd:

SECTION "palette",ROMX,BANK[1]
BGPal:
    dw %0111111111111111, %0000001111100000, \
       %0000000000011111, %0111110000000000  ; WGBR

CoinPal:
    dw %0111111111111111, %0101111110111110, \
       %0011011111011111, %0010101011111111

SECTION "strings", ROMX,BANK[2]
HelloWorldStr:
    db "Hello World!", TEST_TILE, 0
