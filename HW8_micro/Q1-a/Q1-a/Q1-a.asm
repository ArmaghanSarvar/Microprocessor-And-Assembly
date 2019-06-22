.def data= r24		

.org 0x00
rjmp reset

.org 0x002
rjmp int0_routine

.org 0x030

reset:
//sp
	ldi	r16, low(RAMEND)
	out	SPL, r16
	ldi	r16, high(RAMEND)
	out	SPH, r16
//UCSRC
	ldi r16 , (1<<URSEL)|(1<<UCSZ0)|(1<<UCSZ1)|(0<<UMSEL)|(0<<USBS)|(1<<UPM1)
	out UCSRC , r16
//UCSRB
	ldi r16 , (1<<TXEN)|(1<<UCSZ2)
	out UCSRB , r16
//UBRR   baud rate
	ldi r16 , 0x00
	out UBRRH , r16
	ldi r16 , 0b11001111
	out UBRRL , r16 ;it should be 207
//port settings
	ldi r16, 0b11110000
	out DDRC,r16
	ldi r17, 0b00001111
	out PORTC,r17

	ldi r16, (0 << DDD2)
	out DDRD,r16
	ldi r17, (1 << PD2) 
	out PORTD,r17
//GICR
	ldi r16, (1 << INT0)
	out GICR,r16
//MCUCR			 
	ldi R19, (1 << ISC01)	;falling edge
	out MCUCR,R19
	sei
	rjmp loop

loop:
	rjmp loop

int0_routine: 
sbis pinc , 0
rjmp c4
rjmp notc4
notc4:
	sbic pinc , 1
	rjmp notc3
	rjmp c3
notc3:
	sbic pinc , 2
	rjmp notc2
	rjmp c2
notc2:
	rjmp c1
	
c1:
	ldi r17, 0x1F 
	out PORTC,r17
	sbis pinc , 3
	rjmp c1notr1
	ldi data, '7'
	call data_transmit	

c1notr1:
	ldi r17, 0x2F 
	out PORTC,r17
	sbis pinc , 3
	rjmp c1notr2
	ldi data, '4'
	call data_transmit

c1notr2:
	ldi r17, 0x4F 
	out PORTC,r17
	sbis pinc , 3
	rjmp c1notr3
	ldi data, '1'
	call data_transmit

c1notr3:
	ldi r17, 0x8F 
	out PORTC,r17
	sbis pinc , 3
	nop
	ldi data, 'o'
	call data_transmit
	
c2:
	ldi r17, 0x1F 
	out PORTC,r17
	sbis pinc , 2
	rjmp c2notr1
	ldi data, '8'
	rjmp data_transmit

c2notr1:
	ldi r17, 0x2f
	out PORTC,r17
	sbis pinc , 2
	rjmp c2notr2
	ldi data, '5'
	call data_transmit
	
c2notr2:
	ldi r17, 0x4f 
	out PORTC,r17
	sbis pinc , 2
	rjmp c2notr3
	ldi data, '2'
	call data_transmit

c2notr3:
	ldi r17, 0x8f 
	out PORTC,r17
	sbis pinc , 2
	nop
	ldi data, '0'
	call data_transmit

c3notr1:
	ldi r17, 0x2f 
	out PORTC,r17
	sbis pinc , 1
	rjmp c3notr2
	ldi data, '6'
	call data_transmit

c3:
	ldi r17, 0x1f
	out PORTC,r17
	sbis pinc , 1
	rjmp c3notr1
	ldi data, '9'
	rjmp data_transmit
	
c3notr2:
	ldi r17, 0x4f 
	out PORTC,r17
	sbis pinc , 1
	rjmp c3notr3
	ldi data, '3'
	call data_transmit

c3notr3:
	ldi r17, 0x8F 
	out PORTC,r17
	sbis pinc , 1
	nop
	ldi data, '='
	rjmp data_transmit	
	
c4:
	ldi r17, 0x1F 
	out PORTC,r17
	sbis pinc , 0
	rjmp c4notr1
	ldi data, '%'
	call data_transmit

c4notr1:
	ldi r17, 0x2F 
	out PORTC,r17
	sbis pinc , 0
	rjmp c4notr2
	ldi data, '*'
	call data_transmit
	
c4notr2:
	ldi r17, 0x4F 
	out PORTC,r17
	sbis pinc , 0
	rjmp c4notr3
	ldi data, '-'
	call data_transmit

c4notr3:
	ldi r17, 0x8F 
	out PORTC,r17
	sbis pinc , 0
	nop
	ldi data, '+'
	call data_transmit

data_transmit:
	ldi r19, 0x0f 
	out PORTC,r19
	sbis UCSRA , UDRE
	rjmp loop
	out UDR , data		
	reti