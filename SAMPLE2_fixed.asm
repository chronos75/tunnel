; SAMPLE2_fixed.asm - A simple Plus/4 demo (syntax-corrected)
;
; Assembler-friendly variant of the provided source.
; Main fixes:
; - explicit label colons
; - <label / >label for low/high bytes
; - BASIC SYS line corrected to match start address
; - cleaned directive usage (org/dw/db)

        org $1001

HorizPos      = $E0   ; variables
ScrollCount   = $E1
ScrollPos     = $0F70 ; screen position

; --- BASIC line: 10 SYS4109
        dw basic_end
        dw 10
        db $9E,"4109",0
basic_end:
        dw 0

; --- machine code start ($100D = 4109)
start:
        sei                     ; disable interrupts

        jsr ClearScreen

        lda #$00
        sta $FF3F               ; enable RAM

        jsr WriteGreeting

main:
        ; --- set up reset vector
        ldx #<main
        ldy #>main
        stx $FFFC
        sty $FFFD

        ; --- set up IRQ vector
        ldx #<irq
        ldy #>irq
        stx $FFFE
        sty $FFFF

        lda #$AE
        sta $FF0B               ; raster line

        cli

main2:
        lda #$7F                ; query keyboard
        sta $FD30
        sta $FF08
        lda $FF08
        and #$10                ; check for space pressed
        bne main2

        ; --- end of program
        sei
        lda #$00
        sta $FF3E               ; enable ROM
        jmp $FFF6               ; reset

; ################ THE IRQ ################
irq:
        pha                     ; save A
        txa
        pha                     ; save X
        tya
        pha                     ; save Y

        lda $FF09               ; clear interrupt bit
        sta $FF09

        ; (2) adjust horiz scroll TED register
        lda HorizPos
        sta $FF07               ; horiz scroll

        ; (3) rasterbar
        ldx #17                 ; 18 colors
        ldy #$A8                ; vertical position
loop06:
        lda Colors,x            ; next color
loop05:
        cpy $FF1E               ; wait for vertical pos
        bcs loop05
        sta $FF19               ; border
        sta $FF15               ; background
        dex
        bpl loop06

        ; (4) restore color and scroll regs
        lda #$08
        sta $FF07

        ; (5) do scroll work
        ldx HorizPos
        dex
        bpl loop07

        ; copy characters on screen (every 8th time)
        ldx #$00
loop08:
        lda ScrollPos+1,x
        sta ScrollPos,x
        inx
        cpx #$27
        bne loop08

        ; put new character onto screen
        ldx ScrollCount
loop10:
        lda ScrollText,x
        cmp #$FF
        bne loop09
        ldx #$00
        jmp loop10

loop09:
        cmp #$40
        bcc put2
        and #$1F
put2:
        sta ScrollPos+39
        inx
        stx ScrollCount

        ldx #$07
loop07:
        stx HorizPos

        ; --- end of IRQ
        pla
        tay                     ; restore Y
        pla
        tax                     ; restore X
        pla                     ; restore A
        rti

ClearScreen:
        ; clear color RAM page(s)
        ldx #$04                ; number of pages
        ldy #$08                ; hi byte ($0800)
        lda #$09                ; fill byte
        jsr $C5A7

        ; clear screen chars
        ldx #$04
        ldy #$0C                ; hi byte ($0C00)
        lda #$20                ; space
        jsr $C5A7
        rts

WriteGreeting:
        ldx #greetinge-greeting-1
loop04:
        lda greeting,x
        cmp #$40
        bcc put1
        and #$1F
put1:
        sta $0D24,x
        lda #$77                ; yellow
        sta $0924,x
        dex
        bpl loop04

        ldx #message2e-message2-1
loop04a:
        lda message2,x
        cmp #$40
        bcc put1a
        and #$1F
put1a:
        sta $0D72,x
        lda #$57
        sta $0972,x
        dex
        bpl loop04a
        rts

Colors:
        db $00
        db $07,$17,$27,$37,$47,$57,$67,$77
        db $71
        db $79,$69,$59,$49,$39,$29,$19,$09

greeting:
        db "plus4ide example"
greetinge:

message2:
        db "press space to exit."
message2e:

ScrollText:
        db "hello everyone! "
        db "csabo is proud to present "
        db "this 1x1 scroller! "
        db "it is achieved by adjusting the ff07 register "
        db "and copying characters in the video memory... "
        db "text will now restart... "
        db $FF
