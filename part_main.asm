!source "buildcfg.inc"
!source "!playerv.asm"
!source "timing_driver4x.asm"
!source "effect_wire_mc.asm"
!source "flash.asm"

* = $1001
; BASIC: 10 SYS4109
!word .next
!word 10
!byte $9e
!text "4109"
!byte 0
.next:
!word 0

* = $100d
ENTRY:
    sei
    lda #0
    sta subtick
    sta frameCounterLo
    sta frameCounterHi
    sta phaseCounter
    sta kickCounter

    jsr PLAYER_INIT
    jsr EFFECT_INIT
    jsr FLASH_INIT_IN

    ; install IRQ
    lda #<IRQ_HANDLER
    sta $fffe
    lda #>IRQ_HANDLER
    sta $ffff
    cli

MAIN_LOOP:
    lda frameCounterHi
    cmp #>PART_DURATION_FRAMES
    bcc .run
    lda frameCounterLo
    cmp #<PART_DURATION_FRAMES
    bcc .run
    jsr FLASH_INIT_OUT

.waitOut:
    lda flash_state
    bne .waitOut
!if STANDALONE_TEST = 1 {
    jmp ENTRY
}
!if DEMO_IOLIB_EXO = 1 {
    rts
}

.run:
    jmp MAIN_LOOP

!if DEMO_IOLIB_EXO = 1 {
DEMO_LOADER_SLICE:
    ; called once per frame on subtick0 only
    ; hook for siziolib+exo decrunch step while music runs
    rts
}
