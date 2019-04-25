/*
 * Q1_9531807.asm
 *
 *  Created: 4/18/2019 12:42:25 PM
 *   Author: Armaghan
 */ 

 /* in this program I coded part b and c in the same segment and implemented
  7 segment part which is more complete */
  .include "m16def.inc"
 rjmp start
 .org 0x002
 jmp keyFind
 .org 0x004
 jmp ext_int1

 start:
   //Stack pointer settings
	ldi r16 , low(RAMEND) 
	out SPL , r16 
	ldi r16 , high(RAMEND) 
	out SPH , r16
  //PortD settings for part a 
	ldi r16 , 0b00100000 ; direction
	ldi r17 , 0b00001100    
	out DDRD , r16
	out PORTD , r17
  //PortC settings for part b
	ldi r16 , 0b11110000
	ldi r17 , 0b00001111
	out DDRC , r16
	out PORTC , r17
  //PortB settings for part c
	ldi r16, 0Xff
	out DDRB, r16
  
  //MCUCR
	in r17 , MCUCR
	ldi r17 , (0 << ISC11) | (0 << ISC10) |(0 << ISC00) | (0 << ISC01)
  // 00 -> low level , 01 -> any change , 10 -> falling edge , 11 -> rising edge
	out MCUCR , r17
  //GICR
	in r18 , GICR
	ori r18 , (1<<INT1)|(1<<INT0)
	out GICR , r18
 
  //Globally enable all interrupts
  sei
  rjmp loop

loop: rjmp loop

ext_int1:
  in r19 , PIND
  sbis PIND , 5        
  rjmp LED_ON
  rjmp LED_OFF
  ret_label1:
  RETI

LED_ON:
  in r17,PIND
  ldi r17,(1<<PD5)|(1<<PD3)
  out PORTD,r17
  rjmp ret_label1
  
LED_OFF:
  in r16,PIND
  ldi r16,(0<<PD5)|(1<<PD3)
  out PORTD,r16
  rjmp ret_label1

  /////////////////////////////////////////////////////
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
	CALL SET_7segment_0
	cbi PORTC , 4
	 
	sbi PORTC , 5
	sbic PINC , 0
	CALL SET_7segment_4
	cbi PORTC , 5

	sbi PORTC , 6
	sbic PINC , 0
	CALL SET_7segment_8
	cbi PORTC , 6

	sbi PORTC , 7
	sbic PINC , 0
	CALL SET_7segment_C
	cbi PORTC , 7

	rjmp ret_label2

second_col:
	sbi PORTC , 4
	sbic PINC , 1
	CALL SET_7segment_1
	cbi PORTC , 4
	 
	sbi PORTC , 5
	sbic PINC , 1
	CALL SET_7segment_5
	cbi PORTC , 5

	sbi PORTC , 6
	sbic PINC , 1
	CALL SET_7segment_9
	cbi PORTC , 6

	sbi PORTC , 7
	sbic PINC , 1
	CALL SET_7segment_D
	cbi PORTC , 7

	rjmp ret_label2

third_col:
	sbi PORTC , 4
	sbic PINC , 2
	CALL SET_7segment_2
	cbi PORTC , 4
	 
	sbi PORTC , 5
	sbic PINC , 2
	CALL SET_7segment_6
	cbi PORTC , 5

	sbi PORTC , 6
	sbic PINC , 2
	CALL SET_7segment_A
	cbi PORTC , 6

	sbi PORTC , 7
	sbic PINC , 2
	CALL SET_7segment_E
	cbi PORTC , 7

	rjmp ret_label2

fourth_col:
	sbi PORTC , 4
	sbic PINC , 3
	CALL SET_7segment_3
	cbi PORTC , 4
	 
	sbi PORTC , 5
	sbic PINC , 3
	CALL SET_7segment_7
	cbi PORTC , 5

	sbi PORTC , 6
	sbic PINC , 3
	CALL SET_7segment_B
	cbi PORTC , 6

	sbi PORTC , 7
	sbic PINC , 3
	CALL SET_7segment_F
	cbi PORTC , 7

	rjmp ret_label2

SET_7segment_0:
	LDI R16, 0x3F;1
	OUT PORTB, R16
RET

SET_7segment_1:
	LDI R16, 0x06
	OUT PORTB, R16
RET

SET_7segment_2:
	LDI R16, 0x5B
	OUT PORTB, R16
RET

SET_7segment_3:
	LDI R16, 0x4F
	OUT PORTB, R16	
RET

SET_7segment_4:
	LDI R16, 0x66
	OUT PORTB, R16
RET
	
SET_7segment_5:
	LDI R16, 0x6D
	OUT PORTB, R16
RET

SET_7segment_6:
	LDI R16, 0x7D
	OUT PORTB, R16
RET

SET_7segment_7:
	LDI R16, 0x07
	OUT PORTB, R16
RET

SET_7segment_8:
	LDI R16, 0x7F
	OUT PORTB, R16
RET

SET_7segment_9:
	LDI R16, 0x6F
	OUT PORTB, R16
RET

SET_7segment_A:
	LDI R16, 0x77
	OUT PORTB, R16
RET

SET_7segment_B:
	LDI R16, 0x7C
	OUT PORTB, R16
RET

SET_7segment_C:
	LDI R16, 0x61
	OUT PORTB, R16
RET

SET_7segment_D:
	LDI R16, 0x5E
	OUT PORTB, R16
RET

SET_7segment_E:
	LDI R16, 0x79
	OUT PORTB, R16
RET

SET_7segment_F:
	LDI R16, 0x71
	OUT PORTB, R16
RET