/*
 * HW9_one.asm
 *
 *  Created: 5/30/2019 5:34:19 PM
 *   Author: Armaghan
 */ 

 start:
	ldi r16 , low(RAMEND)
	out spl , r16
	ldi r16 , high(RAMEND)
	out sph , r16
	call read_1500
	call write_2500
read_1500 :
	ldi r16, 0x00
	ldi r17, 0x15
	ldi r18, 0xff
	out DDRA, r18 
	out DDRB, r18 
	ldi r18, 0x00
	out DDRC, r18 
	andi r17, 0x3f ; Clear the 2 MS Bits
	andi r17, 0xbf ; Output enabled.
	ori r17, 0x80
	out PORTA, r16 
	out PORTB, r17 
	nop 
	nop
	nop
	nop
	nop
	nop
	nop
	in r0, PINC
ret
write_2500:
	ldi r16, 0x00
	ldi r17, 0x25
	ldi r18, 0x90
	ldi r19, 0xff
	out DDRA, r19 
	out DDRB, r19 
	out DDRC, r16 
	
	andi r17, 0x3f ; Clear the 2 MS Bits
	ori r17, 0x40
	out PORTA, r16 
	out PORTB, r17 ; EPROM is enabled.
	out PORTC, r18 
	nop 
	nop
	sbi PORTB, 7 
	nop
ret