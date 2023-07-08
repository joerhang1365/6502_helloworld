PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

 .org $8000

reset:
  ldx #$ff       ; load $ff to x
  txs            ; transfer x value to stack pointer

  lda #%11111111 ; set all pins on port B to output
  sta DDRB
  lda #%11100000 ; set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; set 8-bit mode; 2-line dipslay; 5x8 font;
  jsr lcd_instruction
  lda #%00001110 ; display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; increment and shift cursor; do not shift display
  jsr lcd_instruction
  lda #%00000001 ; clear display
  jsr lcd_instruction

  ldx #0
print_string:
  lda message,x
  beq loop
  jsr print_char
  inx
  jmp print_string
  
message: .asciiz "Hello, world."

loop:
 jmp loop

lcd_wait:
 pha
 lda #%00000000 ; port b is input
 sta DDRB
lcd_busy:
 lda #RW
 sta PORTA
 lda #(RW | E)
 sta PORTA
 lda PORTB
 and #%10000000
 bne lcd_busy

 lda #RW
 sta PORTA
 lda #%11111111 ; port b is output
 sta DDRB
 pla
 rts

lcd_instruction:
 jsr lcd_wait
 sta PORTB
 lda #0           ; clear rs/rw/e bits
 sta PORTA
 lda #E           ; set enable bit to send instruction
 sta PORTA
 lda #0           ; clear rs/rw/e bits
 sta PORTA
 rts

print_char:
 jsr lcd_wait
 sta PORTB
 lda #RS         ; clear rs; clear rw/e bits
 sta PORTA
 lda #(RS | E)   ; set enable bit to send instruction
 sta PORTA
 lda #RS         ; clear rs/rw/e bits
 sta PORTA
 rts


 .org $fffc
 .word reset
 .word $0000
