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
.segment "VECTORS"
.segment "CHARS"

.segment "STARTUP"
reset:
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
main:
    lda #$01
    sta $0200
    lda #$05
    sta $0201
    lda #$08
    sta $0202
