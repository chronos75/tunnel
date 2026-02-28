; Main effect in a safe text-mode debug presentation.
; This keeps rendering visible without depending on TED bitmap setup.

BITMAP_BASE = $4000
SCREEN_BASE = $0c00
COLOR_BASE  = $0800

EFFECT_VIDEO_INIT
        ldx #$00
clear_loop
        lda #$20
        sta SCREEN_BASE,x
        lda #$01
        sta COLOR_BASE,x
        inx
        bne clear_loop
        rts

EFFECT_INIT
        lda #$00
        sta ef_phase
        sta ef_prev
        rts

EFFECT_FRAME
        ; erase previous cursor
        ldx ef_prev
        lda #$20
        sta SCREEN_BASE,x
        lda #$01
        sta COLOR_BASE,x

        ; draw current cursor
        ldx ef_phase
        lda #$51
        sta SCREEN_BASE,x
        txa
        and #$0f
        sta COLOR_BASE,x

        stx ef_prev
        inc ef_phase
        rts

ef_phase db $00
ef_prev  db $00

; Reserved LUT/table section (kept for later bitmap mode path).
fadeLUT
        db $00,$00,$01,$02,$00,$00,$01,$02,$04,$04,$05,$06,$08,$08,$09,$0a
        db $00,$00,$01,$02,$00,$00,$01,$02,$04,$04,$05,$06,$08,$08,$09,$0a
        db $10,$10,$11,$12,$10,$10,$11,$12,$14,$14,$15,$16,$18,$18,$19,$1a
        db $20,$20,$21,$22,$20,$20,$21,$22,$24,$24,$25,$26,$28,$28,$29,$2a
        db $00,$00,$01,$02,$00,$00,$01,$02,$04,$04,$05,$06,$08,$08,$09,$0a
        db $00,$00,$01,$02,$00,$00,$01,$02,$04,$04,$05,$06,$08,$08,$09,$0a
        db $10,$10,$11,$12,$10,$10,$11,$12,$14,$14,$15,$16,$18,$18,$19,$1a
        db $20,$20,$21,$22,$20,$20,$21,$22,$24,$24,$25,$26,$28,$28,$29,$2a
        db $40,$40,$41,$42,$40,$40,$41,$42,$44,$44,$45,$46,$48,$48,$49,$4a
        db $40,$40,$41,$42,$40,$40,$41,$42,$44,$44,$45,$46,$48,$48,$49,$4a
        db $50,$50,$51,$52,$50,$50,$51,$52,$54,$54,$55,$56,$58,$58,$59,$5a
        db $60,$60,$61,$62,$60,$60,$61,$62,$64,$64,$65,$66,$68,$68,$69,$6a
        db $80,$80,$81,$82,$80,$80,$81,$82,$84,$84,$85,$86,$88,$88,$89,$8a
        db $80,$80,$81,$82,$80,$80,$81,$82,$84,$84,$85,$86,$88,$88,$89,$8a
        db $90,$90,$91,$92,$90,$90,$91,$92,$94,$94,$95,$96,$98,$98,$99,$9a
        db $a0,$a0,$a1,$a2,$a0,$a0,$a1,$a2,$a4,$a4,$a5,$a6,$a8,$a8,$a9,$aa
