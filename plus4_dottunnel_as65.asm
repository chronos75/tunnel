;
; plus/4 character mosaic tunnel with custom charset cache (as65 syntax)
; start with: sys 4109
;

	org $1001 - 2
	dw  $1001
	db  $0b,$10,$0a,$00,$9e,"4109",$00,$00,$00

screen_front = $0c00
screen_back  = $2000
color        = $0800
charset_base = $3000
charset_alt  = $3800
bgcolor      = $ff15
mc_color1    = $ff16
mc_color2    = $ff17
border       = $ff19
ted_chctrl   = $ff13
ted_mode     = $ff07
ted_screen   = $ff06
getin        = $ffe4

zp_phase     = $a4
zp_variant   = $a7

	org $100d
start	sei
	lda #$00
	sta bgcolor
	lda #$00
	sta border
	lda #$27
	sta mc_color1
	lda #$b4
	sta mc_color2
	lda #$00
	sta zp_phase
	sta zp_variant
	jsr init_custom_charset
	jsr clear_screens
	jsr clear_color
	cli

mainloop
	jsr read_keys
	jsr apply_variant_registers
	jsr build_ring_cache
	jsr build_color_cache
	jsr render_tunnel_to_backbuffer
	jsr blit_backbuffer
	jsr render_color_from_map
	dec zp_phase
	jmp mainloop

; ------------------------------------------------------------
read_keys
	jsr getin
	cmp #$31
	bne rk_2
	lda #$00
	sta zp_variant
	rts
rk_2
	cmp #$32
	bne rk_3
	lda #$01
	sta zp_variant
	rts
rk_3
	cmp #$33
	bne rk_end
	lda #$02
	sta zp_variant
rk_end
	rts

; ------------------------------------------------------------
apply_variant_registers
	lda zp_variant
	beq avr_1
	cmp #$01
	beq avr_2
	lda #$26
	sta mc_color1
	lda #$c4
	sta mc_color2
	lda #$00
	sta border
	rts
avr_2
	lda #$35
	sta mc_color1
	lda #$a7
	sta mc_color2
	lda #$00
	sta border
	rts
avr_1
	lda #$27
	sta mc_color1
	lda #$b4
	sta mc_color2
	lda #$00
	sta border
	rts

; ------------------------------------------------------------
init_custom_charset
	ldx #$00
ics_loop
	lda custom_charset,x
	sta charset_base,x
	sta charset_alt,x
	inx
	bne ics_loop
	lda #$3b
	sta ted_screen
	lda #$fc
	sta ted_chctrl
	lda ted_mode
	and #$40
	ora #$98
	sta ted_mode
	rts

; ------------------------------------------------------------
clear_screens
	ldx #$00
cs0
	lda #$20
	sta screen_front,x
	sta screen_back,x
	inx
	bne cs0
	ldx #$00
cs1
	lda #$20
	sta screen_front+$100,x
	sta screen_back+$100,x
	inx
	bne cs1
	ldx #$00
cs2
	lda #$20
	sta screen_front+$200,x
	sta screen_back+$200,x
	inx
	bne cs2
	ldx #$00
cs3
	lda #$20
	sta screen_front+$300,x
	sta screen_back+$300,x
	inx
	bne cs3
	rts

clear_color
	ldx #$00
cc0
	lda #$91
	sta color,x
	inx
	bne cc0
	ldx #$00
cc1
	lda #$91
	sta color+$100,x
	inx
	bne cc1
	ldx #$00
cc2
	lda #$91
	sta color+$200,x
	inx
	bne cc2
	ldx #$00
cc3
	lda #$91
	sta color+$300,x
	inx
	bne cc3
	rts

; ------------------------------------------------------------
build_ring_cache
	ldy #$00
brc_loop
	tya
	clc
	adc zp_phase
	and #$1f
	tax
	lda zp_variant
	beq brc_v1
	cmp #$01
	beq brc_v2
	lda stripe_chars3,x
	jmp brc_store
brc_v2
	lda stripe_chars2,x
	jmp brc_store
brc_v1
	lda stripe_chars1,x
brc_store
	sta ring_cache,y
	iny
	cpy #$20
	bne brc_loop
	rts

build_color_cache
	ldy #$00
bcc_loop
	tya
	clc
	adc zp_phase
	and #$1f
	tax
	lda zp_variant
	beq bcc_v1
	cmp #$01
	beq bcc_v2
	lda wave_colors3,x
	jmp bcc_store
bcc_v2
	lda wave_colors2,x
	jmp bcc_store
bcc_v1
	lda wave_colors1,x
bcc_store
	sta color_cache,y
	iny
	cpy #$20
	bne bcc_loop
	rts

; ------------------------------------------------------------
render_tunnel_to_backbuffer
	ldy #$00
rt0
	lda radius_map,y
	tax
	lda ring_cache,x
	sta screen_back,y
	iny
	bne rt0
	ldy #$00
rt1
	lda radius_map+$100,y
	tax
	lda ring_cache,x
	sta screen_back+$100,y
	iny
	bne rt1
	ldy #$00
rt2
	lda radius_map+$200,y
	tax
	lda ring_cache,x
	sta screen_back+$200,y
	iny
	bne rt2
	ldy #$00
rt3
	lda radius_map+$300,y
	tax
	lda ring_cache,x
	sta screen_back+$300,y
	iny
	bne rt3
	rts

blit_backbuffer
	ldy #$00
bb0
	lda screen_back,y
	sta screen_front,y
	iny
	bne bb0
	ldy #$00
bb1
	lda screen_back+$100,y
	sta screen_front+$100,y
	iny
	bne bb1
	ldy #$00
bb2
	lda screen_back+$200,y
	sta screen_front+$200,y
	iny
	bne bb2
	ldy #$00
bb3
	lda screen_back+$300,y
	sta screen_front+$300,y
	iny
	bne bb3
	rts

render_color_from_map
	ldy #$00
rc0
	lda radius_map,y
	tax
	lda color_cache,x
	ora #$80
	sta color,y
	iny
	bne rc0
	ldy #$00
rc1
	lda radius_map+$100,y
	tax
	lda color_cache,x
	ora #$80
	sta color+$100,y
	iny
	bne rc1
	ldy #$00
rc2
	lda radius_map+$200,y
	tax
	lda color_cache,x
	ora #$80
	sta color+$200,y
	iny
	bne rc2
	ldy #$00
rc3
	lda radius_map+$300,y
	tax
	lda color_cache,x
	ora #$80
	sta color+$300,y
	iny
	bne rc3
	rts

; ------------------------------------------------------------
stripe_chars1
	db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	db 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
stripe_chars2
	db 0,2,4,6,8,10,12,14,15,13,11,9,7,5,3,1
	db 1,3,5,7,9,11,13,15,14,12,10,8,6,4,2,0
stripe_chars3
	db 0,1,3,5,7,9,11,13,15,14,12,10,8,6,4,2
	db 0,2,4,6,8,10,12,14,15,13,11,9,7,5,3,1

wave_colors1
	db $14,$24,$34,$44,$54,$64,$74,$84,$94,$84,$74,$64,$54,$44,$34,$24
	db $14,$16,$26,$36,$46,$56,$66,$76,$86,$76,$66,$56,$46,$36,$26,$16
wave_colors2
	db $16,$26,$36,$46,$56,$66,$76,$86,$96,$a6,$96,$86,$76,$66,$56,$46
	db $36,$26,$16,$13,$23,$33,$43,$53,$63,$73,$63,$53,$43,$33,$23,$13
wave_colors3
	db $13,$23,$33,$43,$53,$63,$73,$83,$93,$83,$73,$63,$53,$43,$33,$23
	db $14,$24,$34,$44,$54,$64,$74,$84,$74,$64,$54,$44,$34,$24,$14,$13

ring_cache
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
color_cache
	db $91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91
	db $91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91

custom_charset
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $11,$11,$11,$11,$11,$11,$11,$11
	db $55,$55,$55,$55,$55,$55,$55,$55
	db $77,$77,$77,$77,$77,$77,$77,$77
	db $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	db $ee,$ee,$ee,$ee,$ee,$ee,$ee,$ee
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $44,$44,$44,$44,$44,$44,$44,$44
	db $af,$af,$af,$af,$af,$af,$af,$af
	db $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
	db $44,$11,$44,$11,$44,$11,$44,$11
	db $22,$88,$22,$88,$22,$88,$22,$88
	db $39,$39,$c6,$c6,$39,$39,$c6,$c6
	db $c3,$c3,$3c,$3c,$c3,$c3,$3c,$3c
	db $5a,$a5,$5a,$a5,$5a,$a5,$5a,$a5
	db $96,$69,$96,$69,$96,$69,$96,$69
	db $18,$3c,$7e,$ff,$ff,$7e,$3c,$18
	db $81,$42,$24,$18,$18,$24,$42,$81
	db $f0,$d8,$cc,$c6,$c6,$cc,$d8,$f0
	db $0f,$1b,$33,$63,$63,$33,$1b,$0f
	db $11,$22,$44,$88,$88,$44,$22,$11
	db $88,$44,$22,$11,$11,$22,$44,$88
	db $fe,$82,$ba,$aa,$aa,$ba,$82,$fe
	db $7e,$42,$5a,$5a,$5a,$5a,$42,$7e
	db $10,$38,$7c,$fe,$7c,$38,$10,$00
	db $04,$0e,$1f,$3f,$1f,$0e,$04,$00
	db $80,$c0,$e0,$f0,$e0,$c0,$80,$00
	db $01,$03,$07,$0f,$07,$03,$01,$00
	db $55,$aa,$55,$aa,$55,$aa,$55,$aa
	db $aa,$55,$aa,$55,$aa,$55,$aa,$55
	db $11,$11,$ee,$ee,$11,$11,$ee,$ee
	db $ee,$ee,$11,$11,$ee,$ee,$11,$11

radius_map
	db 31,30,29,28,27,27,26,25,25,24,23,23,22,22,22,21
	db 21,21,21,21,21,21,21,21,21,22,22,22,23,23,24,25
	db 25,26,27,27,28,29,30,31,29,29,28,27,26,25,25,24
	db 23,22,22,21,21,20,20,20,19,19,19,19,19,19,19,19
	db 20,20,20,21,21,22,22,23,24,25,25,26,27,28,29,29
	db 28,27,27,26,25,24,23,22,22,21,20,20,19,19,18,18
	db 18,17,17,17,17,17,17,18,18,18,19,19,20,20,21,22
	db 22,23,24,25,26,27,27,28,27,26,25,25,24,23,22,21
	db 20,20,19,18,18,17,17,16,16,16,15,15,15,15,16,16
	db 16,17,17,18,18,19,20,20,21,22,23,24,25,25,26,27
	db 26,25,24,23,23,22,21,20,19,18,17,17,16,16,15,15
	db 14,14,14,14,14,14,14,14,15,15,16,16,17,17,18,19
	db 20,21,22,23,23,24,25,26,26,25,24,23,22,21,20,19
	db 18,17,16,15,15,14,13,13,13,12,12,12,12,12,12,13
	db 13,13,14,15,15,16,17,18,19,20,21,22,23,24,25,26
	db 25,24,23,22,21,20,19,18,17,16,15,14,13,13,12,11
	db 11,10,10,10,10,10,10,11,11,12,13,13,14,15,16,17
	db 18,19,20,21,22,23,24,25,24,23,22,21,20,19,18,17
	db 16,15,14,13,12,11,10,10,9,9,9,8,8,9,9,9
	db 10,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
	db 24,23,22,20,19,18,17,16,15,14,13,12,11,10,9,8
	db 8,7,7,7,7,7,7,8,8,9,10,11,12,13,14,15
	db 16,17,18,19,20,22,23,24,24,22,21,20,19,18,16,15
	db 14,13,12,11,10,9,8,7,6,6,5,5,5,5,6,6
	db 7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,24
	db 23,22,21,20,19,17,16,15,14,13,11,10,9,8,7,6
	db 5,4,3,3,3,3,4,5,6,7,8,9,10,11,13,14
	db 15,16,17,19,20,21,22,23,23,22,21,20,18,17,16,15
	db 14,12,11,10,9,8,6,5,4,3,2,1,1,2,3,4
	db 5,6,8,9,10,11,12,14,15,16,17,18,20,21,22,23
	db 24,22,21,20,19,17,16,15,14,12,11,10,9,8,6,5
	db 4,3,1,0,0,1,3,4,5,6,8,9,10,11,12,14
	db 15,16,17,19,20,21,22,24,24,23,21,20,19,18,16,15
	db 14,13,12,10,9,8,7,6,4,3,2,2,2,2,3,4
	db 6,7,8,9,10,12,13,14,15,16,18,19,20,21,23,24
	db 24,23,22,21,19,18,17,16,15,13,12,11,10,9,8,7
	db 6,5,4,4,4,4,5,6,7,8,9,10,11,12,13,15
	db 16,17,18,19,21,22,23,24,25,24,23,21,20,19,18,17
	db 16,14,13,12,11,10,9,8,8,7,6,6,6,6,7,8
	db 8,9,10,11,12,13,14,16,17,18,19,20,21,23,24,25
	db 26,25,23,22,21,20,19,18,17,16,15,14,13,12,11,10
	db 10,9,9,8,8,9,9,10,10,11,12,13,14,15,16,17
	db 18,19,20,21,22,23,25,26,27,26,24,23,22,21,20,19
	db 18,17,16,15,14,13,13,12,12,11,11,11,11,11,11,12
	db 12,13,13,14,15,16,17,18,19,20,21,22,23,24,26,27
	db 28,27,26,24,23,22,21,20,19,19,18,17,16,15,15,14
	db 14,13,13,13,13,13,13,14,14,15,15,16,17,18,19,19
	db 20,21,22,23,24,26,27,28,29,28,27,26,25,24,23,22
	db 21,20,19,19,18,17,17,16,16,15,15,15,15,15,15,16
	db 16,17,17,18,19,19,20,21,22,23,24,25,26,27,28,29
	db 30,29,28,27,26,25,24,24,23,22,21,20,20,19,19,18
	db 18,18,17,17,17,17,18,18,18,19,19,20,20,21,22,23
	db 24,24,25,26,27,28,29,30,0,31,30,29,28,27,26,25
	db 24,24,23,22,22,21,21,20,20,20,20,20,20,20,20,20
	db 20,21,21,22,22,23,24,24,25,26,27,28,29,30,31,0
	db 1,0,31,30,29,29,28,27,26,26,25,24,24,23,23,23
	db 22,22,22,22,22,22,22,22,23,23,23,24,24,25,26,26
	db 27,28,29,29,30,31,0,1,3,2,1,0,31,30,30,29
	db 28,28,27,26,26,25,25,25,24,24,24,24,24,24,24,24
	db 25,25,25,26,26,27,28,28,29,30,30,31,0,1,2,3
	db 4,3,3,2,1,0,31,31,30,30,29,28,28,28,27,27
	db 27,26,26,26,26,26,26,27,27,27,28,28,28,29,30,30
	db 31,31,0,1,2,3,3,4,0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
