;*******************************************************************************
;	File:	m8_LCD_4bit.asm
;      Title:	ATmega8 driver for LCD in 4-bit mode (HD44780)
;  Assembler:	AVR assembler/AVR Studio
;    Version:	1.0
;    Created:	April 5th, 2004
;     Target:	ATmega8
; Christoph Redecker, http://www.avrbeginners.net
;*******************************************************************************

; Some notes on the hardware:
;ATmega8 (clock frequency doesn't matter, tested with 1 MHz to 8 MHz)
; PortA.1 -> LCD RS (register select)
; PortA.2 -> LCD RW (read/write)
; PortA.3 -> LCd E (Enable)
; PortA.4 ... PortA.7 -> LCD data.4 ... data.7
; the other LCd data lines can be left open or tied to ground.


/* in this code first part 2 of question 2 is executed and then part 3 */

.include "m16def.inc"

.equ	LCD_RS	= 1
.equ	LCD_RW	= 2
.equ	LCD_E	= 3

.def	temp	= r16
.def	argument= r17		;argument for calling subroutines
.def	return	= r18		;return value from subroutines

.org 0x00
rjmp reset
.org 0x02
rjmp keyFind

reset:
	ldi	temp, low(RAMEND)
	out	SPL, temp
	ldi	temp, high(RAMEND)
	out	SPH, temp
	//PortD settings for part a 
	ldi temp , 0b00000000 ; direction
	ldi r24 , 0b00000100    
	out DDRD , temp
	out PORTD , r24
	//PortC settings
	ldi temp , 0b11110000
	ldi r24 , 0b00001111
	out DDRC , temp
	out PORTC , r24

	//MCUCR
	in temp , MCUCR
	ldi temp , (0 << ISC00) | (0 << ISC01)
    // 00 -> low level , 01 -> any change , 10 -> falling edge , 11 -> rising edge
	out MCUCR , temp
    //GICR
	in temp , GICR
	ori temp , (1<<INT0)
	out GICR , temp
	sei

	rcall	LCD_init

	rcall	LCD_wait
	
loop:	rjmp loop	

 keyFind:
  cli
  SBIS PINC , 0
  rjmp first_col

  SBIS PINC , 1
  rjmp second_col

  SBIS PINC , 2
  rjmp third_col

  SBIS PINC , 3
  rjmp fourth_col
  sei
  ret_label2: RETI

first_col:
  sbi PORTC , 4
  sbic PINC , 0
  CALL LCD0
  cbi PORTC , 4
   
  sbi PORTC , 5
  sbic PINC , 0
  CALL LCD4
  cbi PORTC , 5

  sbi PORTC , 6
  sbic PINC , 0
  CALL LCD8
  cbi PORTC , 6

  sbi PORTC , 7
  sbic PINC , 0
  CALL LCDc
  cbi PORTC , 7

  rjmp ret_label2

second_col:
  sbi PORTC , 4
  sbic PINC , 1
  CALL LCD1
  cbi PORTC , 4
   
  sbi PORTC , 5
  sbic PINC , 1
  CALL LCD5
  cbi PORTC , 5

  sbi PORTC , 6
  sbic PINC , 1
  CALL LCD9
  cbi PORTC , 6

  sbi PORTC , 7
  sbic PINC , 1
  CALL LCDd
  cbi PORTC , 7

  rjmp ret_label2

third_col:
  sbi PORTC , 4
  sbic PINC , 2
  CALL LCD2
  cbi PORTC , 4
   
  sbi PORTC , 5
  sbic PINC , 2
  CALL LCD6
  cbi PORTC , 5

  sbi PORTC , 6
  sbic PINC , 2
  CALL LCDa
  cbi PORTC , 6

  sbi PORTC , 7
  sbic PINC , 2
  CALL LCDe
  cbi PORTC , 7

  rjmp ret_label2

fourth_col:
  sbi PORTC , 4
  sbic PINC , 3
  CALL LCD3
  cbi PORTC , 4
   
  sbi PORTC , 5
  sbic PINC , 3
  CALL LCD7
  cbi PORTC , 5

  sbi PORTC , 6
  sbic PINC , 3
  CALL LCDb
  cbi PORTC , 6

  sbi PORTC , 7
  sbic PINC , 3
  CALL LCDf
  cbi PORTC , 7

  rjmp ret_label2

LCD0:
  rcall  LCD_wait
  ldi  argument, '0'
  rcall  LCD_putchar
  RET
  
LCD1:
  rcall  LCD_wait
  ldi  argument, '1'
  rcall  LCD_putchar
  RET
  
LCD2:
  rcall  LCD_wait
  ldi  argument, '2'
  rcall  LCD_putchar
  RET
  
LCD3:
  rcall  LCD_wait
  ldi  argument, '3'
  rcall  LCD_putchar
  RET
  
LCD4:
  rcall  LCD_wait
  ldi  argument, '4'
  rcall  LCD_putchar
  RET
  
LCD5:
  rcall  LCD_wait
  ldi  argument, '5'
  rcall  LCD_putchar
  RET
  
LCD6:
  rcall  LCD_wait
  ldi  argument, '6'
  rcall  LCD_putchar
  RET
  
LCD7:
  rcall  LCD_wait
  ldi  argument, '7'
  rcall  LCD_putchar
  RET
  
LCD8:
  rcall  LCD_wait
  ldi  argument, '8'
  rcall  LCD_putchar
  RET
  
LCD9:
  rcall  LCD_wait
  ldi  argument, '9'
  rcall  LCD_putchar
  RET

LCDa:
  rcall  LCD_wait
  ldi    argument, 'A'  
  rcall  LCD_putchar
  RET

LCDb:
  rcall  LCD_wait
  ldi  argument, 'b'
  rcall  LCD_putchar
  RET

LCDc:
  rcall  LCD_wait
  ldi  argument, 'C'
  rcall  LCD_putchar
  RET

LCDd:
  rcall  LCD_wait
  ldi  argument, 'D'
  rcall  LCD_putchar
  RET

LCDe:
  rcall  LCD_wait
  ldi  argument, 'e'
  rcall  LCD_putchar
  RET

LCDf:
  rcall  LCD_wait
  ldi  argument, 'f'
  rcall  LCD_putchar
  RET


lcd_command8:	;used for init (we need some 8-bit commands to switch to 4-bit mode!)
	in	temp, DDRA		;we need to set the high nibble of DDRA while leaving
					;the other bits untouched. Using temp for that.
	sbr	temp, 0b11110000	;set high nibble in temp
	out	DDRA, temp		;write value to DDRA again
	in	temp, PortA		;then get the port value
	cbr	temp, 0b11110000	;and clear the data bits
	cbr	argument, 0b00001111	;then clear the low nibble of the argument
					;so that no control line bits are overwritten
	or	temp, argument		;then set the data bits (from the argument) in the
					;Port value
	out	PortA, temp		;and write the port value.
	sbi	PortA, LCD_E		;now strobe E
	nop
	nop
	nop
	cbi	PortA, LCD_E
	in	temp, DDRA		;get DDRA to make the data lines input again
	cbr	temp, 0b11110000	;clear data line direction bits
	out	DDRA, temp		;and write to DDRA
ret

lcd_putchar:
	push	argument		;save the argmuent (it's destroyed in between)
	in	temp, DDRA		;get data direction bits
	sbr	temp, 0b11110000	;set the data lines to output
	out	DDRA, temp		;write value to DDRA
	in	temp, PortA		;then get the data from PortA
	cbr	temp, 0b11111110	;clear ALL LCD lines (data and control!)
	cbr	argument, 0b00001111	;we have to write the high nibble of our argument first
					;so mask off the low nibble
	or	temp, argument		;now set the argument bits in the Port value
	out	PortA, temp		;and write the port value
	sbi	PortA, LCD_RS		;now take RS high for LCD char data register access
	sbi	PortA, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PortA, LCD_E
	pop	argument		;restore the argument, we need the low nibble now...
	cbr	temp, 0b11110000	;clear the data bits of our port value
	swap	argument		;we want to write the LOW nibble of the argument to
					;the LCD data lines, which are the HIGH port nibble!
	cbr	argument, 0b00001111	;clear unused bits in argument
	or	temp, argument		;and set the required argument bits in the port value
	out	PortA, temp		;write data to port
	sbi	PortA, LCD_RS		;again, set RS
	sbi	PortA, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PortA, LCD_E
	cbi	PortA, LCD_RS
	in	temp, DDRA
	cbr	temp, 0b11110000	;data lines are input again
	out	DDRA, temp
ret

lcd_command:	;same as LCD_putchar, but with RS low!
	push	argument
	in	temp, DDRA
	sbr	temp, 0b11110000
	out	DDRA, temp
	in	temp, PortA
	cbr	temp, 0b11111110
	cbr	argument, 0b00001111
	or	temp, argument

	out	PortA, temp
	sbi	PortA, LCD_E
	nop
	nop
	nop
	cbi	PortA, LCD_E
	pop	argument
	cbr	temp, 0b11110000
	swap	argument
	cbr	argument, 0b00001111
	or	temp, argument
	out	PortA, temp
	sbi	PortA, LCD_E
	nop
	nop
	nop
	cbi	PortA, LCD_E
	in	temp, DDRA
	cbr	temp, 0b11110000
	out	DDRA, temp
ret

LCD_getchar:
	in	temp, DDRA		;make sure the data lines are inputs
	andi	temp, 0b00001111	;so clear their DDR bits
	out	DDRA, temp
	sbi	PortA, LCD_RS		;we want to access the char data register, so RS high
	sbi	PortA, LCD_RW		;we also want to read from the LCD -> RW high
	sbi	PortA, LCD_E		;while E is high
	nop
	in	temp, PinA		;we need to fetch the HIGH nibble
	andi	temp, 0b11110000	;mask off the control line data
	mov	return, temp		;and copy the HIGH nibble to return
	cbi	PortA, LCD_E		;now take E low again
	nop				;wait a bit before strobing E again
	nop	
	sbi	PortA, LCD_E		;same as above, now we're reading the low nibble
	nop
	in	temp, PinA		;get the data
	andi	temp, 0b11110000	;and again mask off the control line bits
	swap	temp			;temp HIGH nibble contains data LOW nibble! so swap
	or	return, temp		;and combine with previously read high nibble
	cbi	PortA, LCD_E		;take all control lines low again
	cbi	PortA, LCD_RS
	cbi	PortA, LCD_RW
ret					;the character read from the LCD is now in return

LCD_getaddr:	;works just like LCD_getchar, but with RS low, return.7 is the busy flag
	in	temp, DDRA
	andi	temp, 0b00001111
	out	DDRA, temp
	cbi	PortA, LCD_RS
	sbi	PortA, LCD_RW
	sbi	PortA, LCD_E
	nop
	in	temp, PinA
	andi	temp, 0b11110000
	mov	return, temp
	cbi	PortA, LCD_E
	nop
	nop
	sbi	PortA, LCD_E
	nop
	in	temp, PinA
	andi	temp, 0b11110000
	swap	temp
	or	return, temp
	cbi	PortA, LCD_E
	cbi	PortA, LCD_RW
ret

LCD_wait:				;read address and busy flag until busy flag cleared
	rcall	LCD_getaddr
	andi	return, 0x80
	brne	LCD_wait
	ret

LCD_delay:
	clr	r2
	LCD_delay_outer:
	clr	r3
		LCD_delay_inner:
		dec	r3
		brne	LCD_delay_inner
	dec	r2
	brne	LCD_delay_outer
ret

LCD_init:
	
	ldi	temp, 0b00001110	;control lines are output, rest is input
	out	DDRA, temp
	
	rcall	LCD_delay		;first, we'll tell the LCD that we want to use it
	ldi	argument, 0x20		;in 4-bit mode.
	rcall	LCD_command8		;LCD is still in 8-BIT MODE while writing this command!!!

	rcall	LCD_wait
	ldi	argument, 0x28		;NOW: 2 lines, 5*7 font, 4-BIT MODE!
	rcall	LCD_command		;
	
	rcall	LCD_wait
	ldi	argument, 0x0F		;now proceed as usual: Display on, cursor on, blinking
	rcall	LCD_command
	
	rcall	LCD_wait
	ldi	argument, 0x01		;clear display, cursor -> home
	rcall	LCD_command
	
	rcall	LCD_wait
	ldi	argument, 0x06		;auto-inc cursor
	rcall	LCD_command
ret