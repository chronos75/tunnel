include "buildcfg.inc"

        org $1001-2
        dw $1001
        dw $100b,0
        db $9e,"4109",0,0,0

        org $100d
ENTRY
        sei
        lda #$00
        sta subtick
        sta frameCounterLo
        sta frameCounterHi
        sta phaseCounter
        sta kickCounter

        jsr PLAYER_INIT
        jsr EFFECT_INIT
        jsr FLASH_INIT_IN
        jsr DRIVER_INIT

        lda irq_handler_vec
        sta $fffe
        lda irq_handler_vec+1
        sta $ffff
        cli

irq_handler_vec
        dw IRQ_HANDLER

MAIN_LOOP
        lda frameCounterHi
        cmp #PART_DURATION_HI
        bcc still_run
        bne do_flash_out ; high-byte overflow: duration already exceeded
        lda frameCounterLo
        cmp #PART_DURATION_LO
        bcc still_run

do_flash_out
        jsr FLASH_INIT_OUT
wait_out
        lda flash_state
        bne wait_out

        lda STANDALONE_TEST
        beq return_demo
        jmp ENTRY

return_demo
        rts

still_run
        jmp MAIN_LOOP

DEMO_LOADER_SLICE
        rts

; Place each included module into its own explicit segment so
; AS65 always assembles them into known non-overlapping ranges.
        org $1100
include "!playerv.asm"

        org $1180
include "timing_driver4x.asm"

        org $1280
include "effect_wire_mc.asm"

        org $1400
include "flash.asm"
