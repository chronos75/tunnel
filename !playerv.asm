; Minimal player wrapper with configurable ZP base (as65 syntax)

player_zp_base = MUSIC_ZP_BASE

pzp_tick      = player_zp_base+0
pzp_speed     = player_zp_base+1
pzp_gate      = player_zp_base+2
pzp_shadow0   = player_zp_base+3
pzp_shadow1   = player_zp_base+4
pzp_shadow2   = player_zp_base+5

PLAYER_INIT
        lda #$00
        sta pzp_tick
        lda #$01
        sta pzp_speed
        rts

PLAYER
        inc pzp_tick
        lda pzp_tick
        and #$0f
        sta pzp_shadow0
        rts

PLAYER_SOUND
        clc
        lda pzp_tick
        adc #$01
        sta pzp_shadow1
        rts
