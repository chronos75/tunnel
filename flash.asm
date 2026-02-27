; Flash in / flash out sequencing

flash_state   = $25
flash_timer   = $26
flash_count   = $27

TED_BGCOLOR   = $ff15
TED_BORDERCOL = $ff19

FLASH_INIT_IN
        lda #$01
        sta flash_state
        lda #$08
        sta flash_timer
        lda #$00
        sta flash_count
        rts

FLASH_INIT_OUT
        lda #$02
        sta flash_state
        lda #$08
        sta flash_timer
        lda #$00
        sta flash_count
        rts

FLASH_UPDATE
        lda flash_state
        beq flash_idle

        dec flash_timer
        bne flash_idle

        lda #$08
        sta flash_timer

        inc flash_count
        lda flash_count
        cmp #FLASH_STEPS2
        bcc flash_toggle

        lda #$00
        sta flash_state
        lda #$00
        sta TED_BGCOLOR
        sta TED_BORDERCOL
        rts

flash_toggle
        and #$01
        beq flash_dark

        lda flash_state
        cmp #$01
        beq flash_in_bright
        lda #$01
        bne flash_write
flash_in_bright
        lda #$0f
        bne flash_write

flash_dark
        lda #$00

flash_write
        sta TED_BGCOLOR
        sta TED_BORDERCOL

flash_idle
        rts
