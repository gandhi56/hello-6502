.segment "HEADER"
.byte "NES"
.byte $1a
.byte $02 ; 2 * 16KB PRG ROM
.byte $01 ; 1 * 8KB CHR ROM
.byte %00000001 ; mapper and mirroring
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00 ; filler bytes
.segment "ZEROPAGE" ; LSB 0 - FF
.segment "STARTUP"
Reset:
    sei ; Disables all interrupts
    cld ; disable decimal mode

    ; Disable sound IRQ
    ldx #$40
    stx $4017

    ; Initialize the stack register
    ldx #$FF
    txs

    inx ; #$FF + 1 => #$00

    ; Zero out the PPU registers
    stx $2000
    stx $2001

    stx $4010

VBlankWait1:
    bit $2002
    bpl VBlankWait1

    txa

CLEARMEM:
    sta $0000, X ; $0000 => $00FF
    sta $0100, X ; $0100 => $01FF
    sta $0300, X
    sta $0400, X
    sta $0500, X
    sta $0600, X
    sta $0700, X
    lda #$FF
    sta $0200, X ; $0200 => $02FF
    lda #$00
    inx
    bne CLEARMEM    
; wait for vblank

VBlankWait2:
    bit $2002
    bpl VBlankWait2

    lda #$02
    sta $4014
    NOP

    ; $3F00
    lda #$3F
    sta $2006
    lda #$00
    sta $2006

    ldx #$00

LoadPalettes:
    lda PaletteData, X
    sta $2007 ; $3F00, $3F01, $3F02 => $3F1F
    inx
    cpx #$20
    bne LoadPalettes    

    ldx #$00
LoadSprites:
    lda SpriteData, X
    sta $0200, X
    inx
    cpx #$20
    bne LoadSprites
    
    cli

    lda #%10010000
    sta $2000

    lda #%00011110
    sta $2001

Loop:
    jmp Loop

    ldx #$00
NMI:
    lda #$02 ; copy sprite data from $0200 => PPU memory for display
    sta $4014
    rti

PaletteData:
  .byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F  ;background palette data
  .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data

SpriteData:
  .byte $08, $00, $00, $08
  .byte $08, $01, $00, $10
  .byte $10, $02, $00, $08
  .byte $10, $03, $00, $10
  .byte $18, $04, $00, $08
  .byte $18, $05, $00, $10
  .byte $20, $06, $00, $08
  .byte $20, $07, $00, $10

.segment "VECTORS"
    .word NMI
    .word Reset
    ; 
.segment "CHARS"
    .incbin "hellomario.chr"