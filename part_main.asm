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
        sta $ff19      ; heartbeat: confirm main loop is alive
        jsr FLASH_UPDATE  ; direct call for debug: no subtick dependency
        jsr EFFECT_FRAME  ; direct call for debug: prove effect path runs
        jsr DRIVER_4X_STEP
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
        jsr DRIVER_4X_STEP
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

; Keep includes contiguous in the same segment so all routines are
; guaranteed to be present in the loaded PRG image.
include "timing_driver4x.asm"
include "effect_wire_mc.asm"
include "flash.asm"
