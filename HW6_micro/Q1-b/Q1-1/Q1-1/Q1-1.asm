/*
 * Q1_1.asm
 *
 *  Created: 4/29/2019 10:36:18 PM
 *   Author: Armaghan
 */ 
 rjmp start

 start:
	//port
	SBI DDRB,3
    SBI PORTB,3

	ldi r16, 0x00
    out TCNT0, r16 
	
	ldi r16 , 0b00011101
	out TCCR0 , r16

	ldi r16 , 0xff
	out OCR0 , r16 
	sei
	rjmp loop

loop:
	rjmp loop
