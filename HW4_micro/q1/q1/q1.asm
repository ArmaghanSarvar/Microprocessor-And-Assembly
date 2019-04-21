/*
 * q1.asm
 *
 *  Created: 4/13/2019 9:40:10 AM
 *   Author: Armaghan
 */ 
 .include "m16def.inc"
 .ORG 0

 .CSEG
 BCDTo7_Seg : .db 0b00111111 , 0b00000110 , 0b01011011 , 0b01001111 , 0b01100110 , 0b01101101 , 0b01111101 , 0b00000111,\
 0b01111111 , 0b01101111

 start:
	//rjmp part_3          // to run part 3(7 segment counter) , uncomment this line
	ldi r16 , high(ramend)  
	out sph , r16		   // because we are calling a subroutine
	ldi r16 , low(ramend)
	out spl , r16 
	ldi r16 , 0b00110000 ; direction
	ldi r19 , 0b01001001    
	out DDRD , r16
	out PORTD , r19
	rjmp LOOP

LOOP:
	in r17 , PIND
	sbis PIND , 6          // part b
	rjmp BLINK
	sbis PIND , 3          // part a
	rjmp LED_ON
	rjmp LED_OFF
	rjmp LOOP

LED_ON:
	ldi r18 , 0b00100000  
	out PORTD , r18
	rjmp LOOP

LED_OFF:
	ldi r18 , 0b00000000
	out PORTD , r18
	rjmp LOOP

BLINK:
	ldi r24 , -5        // 5 times
BLINK1:
	ldi r18 , 0b00010000   // ON
	out PORTD , r18
	call delay
	ldi r18 , 0b00000000   // OFF
	out PORTD , r18
	call delay
	inc r24
	brne BLINK1   // if z = 0
	in r17 , PIND      // polling!
	sbic PIND , 6  
	rjmp LOOP 
	rjmp BLINK

delay:                 // For CLK = 1 MHz
    LDI r20 , 16       // One cycle
delay1:
    LDI r21 , 125     // One cycle
delay2:
    LDI r22 , 250     // One cycle
delay3:
    DEC r22            // One cycle
    NOP                // One cycle
    BRNE delay3        // Two cycles when jumping to Delay3, 1 clock when continuing to DEC

    DEC r21            // One cycle
    BRNE delay2        // Two cycles when jumping to Delay2, 1 clock when continuing to DEC

    DEC r20            // One Cycle
    BRNE delay1        // Two cycles when jumping to Delay1, 1 clock when continuing to RET
RET
/////////////////////////////////////////////////////////
part_3:
	ldi r17 , 0xff     // direction to output
	out DDRB , r17
	ldi ZH , HIGH(BCDTo7_Seg)
	ldi ZL , LOW(BCDTo7_Seg)
	ldi r19 , -10
	rjmp show_7_segment

show_7_segment:
	LPM r17 , Z+
	out PORTB , r17
	call delay
	inc r19
	brne show_7_segment
	rjmp part_3

