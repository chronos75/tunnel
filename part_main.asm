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

        jsr EFFECT_INIT
        jsr FLASH_INIT_IN

MAIN_LOOP
        inc kickCounter
        lda kickCounter
        and #$0f
        sta $ff19      ; flash-only debug marker

        jsr FLASH_UPDATE

        inc frameCounterLo
        bne nofc
        inc frameCounterHi
nofc
        lda frameCounterHi
        cmp #PART_DURATION_HI
        bcc MAIN_LOOP
        bne do_flash_out
        lda frameCounterLo
        cmp #PART_DURATION_LO
        bcc MAIN_LOOP

do_flash_out
        jsr FLASH_INIT_OUT
wait_out
        jsr FLASH_UPDATE
        lda flash_state
        bne wait_out

        lda STANDALONE_TEST
        beq return_demo
        jmp ENTRY

return_demo
        rts

DEMO_LOADER_SLICE
        rts

; Keep includes contiguous in the same segment so all routines are
; guaranteed to be present in the loaded PRG image.
include "timing_driver4x.asm"
include "effect_wire_mc.asm"
include "flash.asm"
