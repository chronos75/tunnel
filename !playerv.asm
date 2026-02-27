; Minimal player wrapper with configurable ZP base
; Original player base was hardcoded to $db.

!ifndef MUSIC_ZP_BASE {
MUSIC_ZP_BASE = $db
}

player_zp_base = MUSIC_ZP_BASE

; reserve 16 bytes from configurable base
pzp_tick      = player_zp_base+0
pzp_speed     = player_zp_base+1
pzp_gate      = player_zp_base+2
pzp_shadow0   = player_zp_base+3
pzp_shadow1   = player_zp_base+4
pzp_shadow2   = player_zp_base+5

PLAYER_INIT:
    lda #0
    sta pzp_tick
    lda #1
    sta pzp_speed
    rts

; Full tick/update call (subtick0)
PLAYER:
    inc pzp_tick
    lda pzp_tick
    and #$0f
    sta pzp_shadow0
    rts

; Lightweight call on subtick1..3
PLAYER_SOUND:
    clc
    lda pzp_tick
    adc #1
    sta pzp_shadow1
    rts
