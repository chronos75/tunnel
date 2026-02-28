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
        inc phaseCounter
        lda phaseCounter
        and #$03
        beq step_flash
        cmp #$01
        beq step_effect
        cmp #$02
        beq step_driver

step_idle
        lda #$0b
        sta $ff19      ; stage 3: idle marker
        jmp check_duration

step_flash
        lda #$02
        sta $ff19      ; stage 0: FLASH_UPDATE
        jsr FLASH_UPDATE
        jmp check_duration

step_effect
        lda #$05
        sta $ff19      ; stage 1: EFFECT_FRAME (isolated: call disabled)
        ; jsr EFFECT_FRAME
        jmp check_duration

step_driver
        lda #$08
        sta $ff19      ; stage 2: DRIVER_4X_STEP
        jsr DRIVER_4X_STEP

check_duration
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
        lda #$0d
        sta $ff19      ; flash-out wait marker
        jsr FLASH_UPDATE
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
