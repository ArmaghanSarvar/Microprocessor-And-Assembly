/*
 * Q1_9531807.asm
 *
 *  Created: 4/27/2019 7:15:18 PM
 *   Author: Armaghan
 */ 

 .def overflows = r17

 rjmp start

 .org 0x012
		JMP check_time

 start:
	ldi r18 , 0
	ldi overflows , 0
	
	//ports
	ldi r16, 0b00110000
	out DDRD, r16
	ldi r16, 0b00110000
	out PORTD, r16  

	//overflow interrupt 
	ldi r16 , (1 << TOIE0)
	out TIMSK , r16
	// prescaler	
	ldi r16 , (1 << CS01) | (1 << CS00)
	out TCCR0 , r16
	sei

loop:
	sei
	rjmp loop

check_time:
	cli
	inc overflows
	cpi overflows, 128
	breq low_eq
	cpi overflows , 0
	breq inc_sec_reg
	end:sei
		jmp loop

inc_sec_reg:
	INC r18
	rjmp end
	
low_eq:
	cpi r18 , 1
	breq threeseconds
	rjmp end
threeseconds:
	in r20 , PIND
	cpi r20 , 0b00110000
	breq make_leds_off
	cpi r20 , 0b00000000
	breq make_leds_on

make_leds_off:
	ldi r16 , 0b00000000
	out PORTD , r16
	ldi overflows , 0
	ldi r18 , 0
	rjmp end

make_leds_on:
	ldi r16 , 0b00110000
	out PORTD , r16
	ldi overflows , 0
	ldi r18 , 0
	rjmp end