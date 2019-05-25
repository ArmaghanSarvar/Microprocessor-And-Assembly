/*
 * HW7_9531807.asm
 *
 *  Created: 5/13/2019 9:44:36 PM
 *   Author: Armaghan
 */ 

rjmp start

start:
	ldi r16 , (1<<PD5)
	out DDRD , r16
	ldi r16 , 0x00
	out PORTD , r16
	ldi r16 , (1<<ACME)
	out SFIOR , r16
	ldi r16 , (0<<MUX2)|(0<<MUX1)|(1<<MUX0)
	out ADMUX , r16
	//ldi r16 , (1<<ACIS1)|(0<<ACIS0)
	//out ACSR , r16
	      
		  
loop:
    sbis ACSR,ACO
    rjmp turnon
    sbic ACSR,ACO
    rjmp turnoff
    rjmp loop
turnon:
    ldi r16,(1<<PD5)
    out PORTD,r16
    rjmp loop
turnoff:
    ldi r16,(0<<PD5)
    out PORTD,r16
    rjmp loop