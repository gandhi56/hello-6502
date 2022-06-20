.segment "HEADER"
.byte "NES"
.byte $1a   ;   this is game file and its loadable
.byte $02   ;   2 * 16KB prg ROM
.byte $01   ;   1 * 8KB  chr ROM
.byte %00000001 ; mapper and mirroring
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00 ; filler bytes

.segment "ZEROPAGE"
.segment "STARTUP"
reset:
    sei ; disables all interrupts
    cld ; disable decimal mode

    ; Disable sound IRQ
    ldx #$40
    stx $4017

    ; Initialize the stack register
    ldx #$FF
    txs
    inx ; #$FF + 1 => #$00

    ; Zero out PPU registers
    stx $2000
    stx $2001

    stx $4010   ; disable APU DMC channel

; Wait for PPU to draw a single frame.
; Everytime PPU draws a frame there is a 
; short time frame called v-blank where 
; PPU waits for a graphics update. By waiting
; for this v-blank event to occur, we will
; ensure that at least a single frame was drawn.
;
; If the seventh bit at $2002 is 1, then we are
; in the v-blank state.
v_blank_wait1:
    bit $2002           ; checks the 7th bit at $2002, 
                        ; sets N if the bit is 1
    bpl v_blank_wait1   

clear_mem:
    lda #$00
    sta $0000, X    ; 0 - 255
    sta $0100, X    ; 256 - 511
    sta $0300, X
    sta $0400, X
    sta $0500, X
    sta $0600, X
    sta $0700, X    ; 1792 - 2047

    lda #$fe
    sta $0200, X    ; move all sprites off screen

    inx
    cpx #$00
    bne clear_mem

    ; PPU and palettes initialization
    lda #$02
    sta $4014
    nop             ; burn an extra cycle to sync

    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    ldx #$00

v_blank_wait2:
    bit $2002
    bpl v_blank_wait2

    lda #$02
    sta $4014
    NOP

    ; $3F00
    lda #$3F
    sta $2006
    lda #$00
    sta $2006

    ldx #$00

load_palettes:
    lda palette_data, X
    sta $2007
    inx
    cpx #$20
    bne load_palettes
    ldx #$00

load_sprites:
    lda sprite_data, X
    sta $0200, X
    inx
    cpx #$20
    bne load_sprites
    cli
    lda #%10010000
    sta $2000
    lda #%00011110
    sta $2001

; loop:
    ; jmp loop
    ; ldx #$00

nmi:
    lda #$02
    sta $4014
    rti

palette_data:
    .byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F  ;background palette data
    .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data


sprite_data:
    .byte $08, $00, $00, $08
    .byte $08, $01, $00, $10
    .byte $10, $02, $00, $08
    .byte $10, $03, $00, $10
    .byte $18, $04, $00, $08
    .byte $18, $05, $00, $10
    .byte $20, $06, $00, $08
    .byte $20, $07, $00, $10

    cli
    lda #%10010000
    sta $2000
    lda #%00011110
    sta $2001

.segment "VECTORS"
    .word nmi
    .word reset
.segment "CHARS"
    .incbin "mario.chr"