; 4x timing driver: subtick0 does frame logic, subtick1..3 are sound only.

!source "buildcfg.inc"

; safe ZP (explicitly not using $a7-$af or $fc-$ff)
subtick        = $20
frameCounterLo = $21
frameCounterHi = $22
phaseCounter   = $23
kickCounter    = $24

IRQ_HANDLER:
    pha
    txa
    pha
    tya
    pha

    jsr DRIVER_4X_STEP

    pla
    tay
    pla
    tax
    pla
    asl $ff09          ; ack TED irq (placeholder)
    rti

DRIVER_4X_STEP:
    lda subtick
    and #$03
    tax
    inx
    txa
    and #$03
    sta subtick

    lda subtick
    bne .sub1to3

.sub0:
    jsr PLAYER

    inc frameCounterLo
    bne .noCarry
    inc frameCounterHi
.noCarry:

    inc phaseCounter
    lda phaseCounter
    and #$03
    bne .noKick
    inc kickCounter
.noKick:

!if DEMO_IOLIB_EXO = 1 {
    jsr DEMO_LOADER_SLICE
}

    jsr FLASH_UPDATE
    jsr EFFECT_FRAME
    rts

.sub1to3:
    jsr PLAYER_SOUND
    rts
