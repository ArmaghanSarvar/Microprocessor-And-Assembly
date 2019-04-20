/*
 * ArmaghanSarvar_HW3_Q5.asm
 *
 *  Created: 3/28/2019 6:33:25 PM
 *   Author: Armaghan
 */ 
 .include "m16def.inc"
 .org 0
 .DEF counter = r24
 .DEF result = r20       // instead of loading on R0 which is not possible

 ldi counter , -20      // array size
 ldi result , 1         // assume ascending
 
 .CSEG
 ARRAY : .db 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t'
 RJMP algo

algo:
    LDI ZH,high(ARRAY)
	LDI ZL,low(ARRAY)
	LPM r16 , Z+
	INC counter
	LPM r17 , Z+
	INC counter
	cp r17 , r16
	brge ascending_or_not_sorted   
	brlt descending_or_not_sorted

ascending_or_not_sorted:
	LPM r16 , Z+
	cp r16 , r17
	brlt not_sorted
	MOV r17 , r16
	INC counter
	brne ascending_or_not_sorted
	rjmp end

descending_or_not_sorted:
	LPM r16 , Z+
	cp r16 , r17
	brge not_sorted
	MOV r17 , r16
	INC counter
	brne descending_or_not_sorted  // branch if Z is 0
	LDI result , 2    // it is descending
	rjmp end

not_sorted:
	LDI result , 0
	rjmp end
end: 
	MOV r0 , result      // because we want R0 as our result
	rjmp end