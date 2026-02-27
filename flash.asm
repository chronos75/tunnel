; Flash in / flash out sequencing via border/background color writes

flash_state   = $25
flash_timer   = $26
flash_count   = $27

TED_BGCOLOR   = $ff15
TED_BORDERCOL = $ff19

FLASH_INIT_IN:
    lda #1
    sta flash_state
    lda #8
    sta flash_timer
    lda #0
    sta flash_count
    rts

FLASH_INIT_OUT:
    lda #2
    sta flash_state
    lda #8
    sta flash_timer
    lda #0
    sta flash_count
    rts

FLASH_UPDATE:
    lda flash_state
    beq .idle

    dec flash_timer
    bne .idle

    lda #8
    sta flash_timer

    inc flash_count
    lda flash_count
    cmp #FLASH_STEPS*2
    bcc .doToggle

    lda #0
    sta flash_state
    lda #0
    sta TED_BGCOLOR
    sta TED_BORDERCOL
    rts

.doToggle:
    and #1
    beq .dark

.bright:
    lda flash_state
    cmp #1
    beq .inBright
    lda #$01
    bne .write
.inBright:
    lda #$0f
    bne .write

.dark:
    lda #0

.write:
    sta TED_BGCOLOR
    sta TED_BORDERCOL

.idle:
    rts
