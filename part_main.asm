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
        sta $ff19      ; baseline diagnostic: border must cycle continuously
        sta $ff15      ; baseline diagnostic: background follows border
        jmp MAIN_LOOP

DEMO_LOADER_SLICE
        rts

; Keep includes contiguous in the same segment so all routines are
; guaranteed to be present in the loaded PRG image.
include "timing_driver4x.asm"
include "effect_wire_mc.asm"
include "flash.asm"
