/*
 * q2.asm
 *
 *  Created: 4/15/2019 9:58:40 PM
 *   Author: Armaghan
 */ 
.include "m16def.inc"
.org 0
start:
	ldi r16 , 0b00100000 ; direction
	ldi r19 , 0b01001000 ; pull up
	out DDRD , r16
	out PORTD , r19

part_a:
	wdr
	in r21, WDTCR
	ori r21, (0<<WDTOE)|(1<<WDE)|(1<<WDP2)|(1<<WDP1)|(1<<WDP0)
	out WDTCR, r21
	rjmp part_b

part_b:
	in r17 , PIND
	sbrs r17 , 3         
	rjmp LED_ON
	rjmp part_b
	
LED_ON:
	;ldi r18 , 0b00100000  
	ori r19 , 0b00100000  
	out PORTD , r19         // make on
	in r17 , PIND           // check sw2
	sbrs r17 , 6
	wdr
	rjmp LED_ON