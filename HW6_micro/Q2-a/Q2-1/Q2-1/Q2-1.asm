/*
 * Q2_1.asm
 *
 *  Created: 4/29/2019 11:02:09 PM
 *   Author: Armaghan
 */ 

 rjmp start

 start:
	//portB settings
	ldi r16, 0b00001000
	out DDRB, r16
	ldi r16, 0b00000000
	out PORTB, r16  
	//portD settings
	ldi r17 , 0b00000000 
	ldi r24 , 0b11000000    
	out DDRD , r17
	out PORTD , r24

	ldi r16,0x00
	out OCR0,r16
	//fast pwm mode , clear on compare match , clk/1024
	ldi r16, 0b01101101
	out TCCR0, r16

	rjmp check
	
check :
	in r16,PIND
	cpi r16,0b01000000
	breq slow
	cpi r16,0b10000000
	breq fast
	cpi r16,0b11000000
	breq off	

slow: 
	ldi r16,100
	out OCR0,r16
	rjmp check

fast: 
	ldi r16,200
	out OCR0,r16
	rjmp check

off:
	ldi r16 , 0
	out OCR0 , r16
	rjmp check
