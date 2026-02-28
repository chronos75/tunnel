; 4x timing driver: subtick0 does frame logic, subtick1..3 are sound only.


DRIVER_INIT
        lda #$00
        sta $ff0b      ; raster line 0
        lda #$02
        sta $ff0a      ; enable TED raster IRQ
        lda $ff09      ; clear any pending TED IRQ
        sta $ff09
        rts

subtick        = $20
frameCounterLo = $21
frameCounterHi = $22
phaseCounter   = $23
kickCounter    = $24

IRQ_HANDLER
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
        lda $ff09
        sta $ff09
        rti

DRIVER_4X_STEP
        lda subtick
        and #$03
        clc
        adc #$01
        and #$03
        sta subtick

        lda subtick
        bne subtick123

subtick0
        jsr PLAYER

        inc frameCounterLo
        bne nocarry
        inc frameCounterHi
nocarry
        inc phaseCounter
        lda phaseCounter
        and #$03
        bne nokick
        inc kickCounter
nokick

        lda DEMO_IOLIB_EXO
        beq no_loader
        jsr DEMO_LOADER_SLICE
no_loader

        jsr FLASH_UPDATE
        jsr EFFECT_FRAME
        rts

subtick123
        jsr PLAYER_SOUND
        rts
