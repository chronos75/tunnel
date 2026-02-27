include "buildcfg.inc"
include "!playerv.asm"
include "timing_driver4x.asm"
include "effect_wire_mc.asm"
include "flash.asm"

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

        lda #<IRQ_HANDLER
        sta $fffe
        lda #>IRQ_HANDLER
        sta $ffff
        cli

MAIN_LOOP
        lda frameCounterHi
        cmp #PART_DURATION_HI
        bcc still_run
        bne do_flash_out
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
