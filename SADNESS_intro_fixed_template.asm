; SADNESS intro - as65 syntax fix template
; Use this file as guidance or generate a full fixed file with:
;   python3 tools/fix_plus4_as65_syntax.py sadness_original.asm SADNESS_intro_fixed.asm
;
; Key manual checks after auto-fix:
; 1) include/include dialect: include vs .include vs !source
; 2) directives: org/dw/db for your exact assembler build
; 3) plus4ide-specific directives (e.g. cmap) availability
;
; Example fixes already reflected below:

        org $1000-2
        dw $1000

        org $1000
        include "sadnessff40.asm"

main:
        ldx #<main
        ldy #>main
        stx $FFFC
        sty $FFFD

        ldx #<irq0
        ldy #>irq0
        stx $FFFE
        sty $FFFF

scrollreset:
        lda #<scrolltext1
        sta scroller1+26
        lda #>scrolltext1
        sta scroller1+27
        rts

scrollreset2:
        lda #<scrolltext2
        sta scroller2+26
        lda #>scrolltext2
        sta scroller2+27
        rts

irq0:
        lda #<irq1
        sta $fffe
        lda #>irq1
        sta $ffff
        rti

irq1:
        lda #<irq2
        sta $fffe
        lda #>irq2
        sta $ffff
        rti

irq2:
        lda #<irq3
        sta $fffe
        lda #>irq3
        sta $ffff
        rti

irq3:
        lda #<irq0
        sta $fffe
        lda #>irq0
        sta $ffff
        rti
