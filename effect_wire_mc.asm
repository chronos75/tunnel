; Multicolor wireframe-ish temporal fade effect
; Uses 256-byte LUT where each 2bpp pixel fades: 3->2->1->0

BITMAP_BASE = $4000

EFFECT_INIT:
    lda #0
    sta ef_phase
    rts

EFFECT_FRAME:
    jsr EFFECT_DRAW_WIREFRAME
    jsr EFFECT_TEMPORAL_FADE
    rts

EFFECT_DRAW_WIREFRAME:
    ldx #0
    lda ef_phase
.drawLoop:
    eor BITMAP_BASE,x
    sta BITMAP_BASE,x
    clc
    adc #$13
    inx
    cpx #$80
    bne .drawLoop
    inc ef_phase
    rts

EFFECT_TEMPORAL_FADE:
    ldx #0
.fadeLoop:
    lda BITMAP_BASE,x
    tay
    lda fadeLUT,y
    sta BITMAP_BASE,x
    inx
    bne .fadeLoop
    rts

ef_phase: !byte 0

fadeLUT:
!byte $00,$00,$01,$02,$00,$00,$01,$02,$04,$04,$05,$06,$08,$08,$09,$0a
!byte $00,$00,$01,$02,$00,$00,$01,$02,$04,$04,$05,$06,$08,$08,$09,$0a
!byte $10,$10,$11,$12,$10,$10,$11,$12,$14,$14,$15,$16,$18,$18,$19,$1a
!byte $20,$20,$21,$22,$20,$20,$21,$22,$24,$24,$25,$26,$28,$28,$29,$2a
!byte $00,$00,$01,$02,$00,$00,$01,$02,$04,$04,$05,$06,$08,$08,$09,$0a
!byte $00,$00,$01,$02,$00,$00,$01,$02,$04,$04,$05,$06,$08,$08,$09,$0a
!byte $10,$10,$11,$12,$10,$10,$11,$12,$14,$14,$15,$16,$18,$18,$19,$1a
!byte $20,$20,$21,$22,$20,$20,$21,$22,$24,$24,$25,$26,$28,$28,$29,$2a
!byte $40,$40,$41,$42,$40,$40,$41,$42,$44,$44,$45,$46,$48,$48,$49,$4a
!byte $40,$40,$41,$42,$40,$40,$41,$42,$44,$44,$45,$46,$48,$48,$49,$4a
!byte $50,$50,$51,$52,$50,$50,$51,$52,$54,$54,$55,$56,$58,$58,$59,$5a
!byte $60,$60,$61,$62,$60,$60,$61,$62,$64,$64,$65,$66,$68,$68,$69,$6a
!byte $80,$80,$81,$82,$80,$80,$81,$82,$84,$84,$85,$86,$88,$88,$89,$8a
!byte $80,$80,$81,$82,$80,$80,$81,$82,$84,$84,$85,$86,$88,$88,$89,$8a
!byte $90,$90,$91,$92,$90,$90,$91,$92,$94,$94,$95,$96,$98,$98,$99,$9a
!byte $a0,$a0,$a1,$a2,$a0,$a0,$a1,$a2,$a4,$a4,$a5,$a6,$a8,$a8,$a9,$aa
