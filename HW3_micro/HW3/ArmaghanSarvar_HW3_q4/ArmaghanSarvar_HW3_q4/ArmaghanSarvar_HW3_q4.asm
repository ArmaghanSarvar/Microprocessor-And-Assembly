/*
 * q4.asm
 *
 *  Created: 3/26/2019 5:13:05 PM
 *   Author: Armaghan
 */ 


 /* in this question if we set sph = 0x00 and spl = 0x90 then after adding
  Z = 0x70 with 0x20 we will get to value of sp 
  so that the address of stack pointer will be overwritten and causes problem
  so instead of sph = 0x00 and spl = 0x90 I set the value of stack pointer equal to RAMEND
  */

.include "m16def.inc"
.ORG 0
 LDI r16, high(ramend)
 OUT SPH, r16
 LDI r16, low(ramend)       //due to the comment above
 OUT SPL, r16

start:
	LDI ZH, 0
	LDI ZL, 0b01110000    //0x070 in Z
	/*
	I first wanted to write some value in io register 0x30 and 
	then read that value but we can't write on 0x30 and it's 3MSB are reserved (we can't change them)
	so I used address 0x00
	to test writing in port before reading it
	*/
	;LDI r16, 0b01111111         //r16 = 0x7f
	;out 0x00 , r16
	;RJMP last_part
	RJMP subroutine

subroutine:
	IN r0, 0X30      // if we assume some value is written on 0x30... but I tested with 0x00
	SWAP r0
	LDI r17 , 0b11110111
	AND r0 , r17
	BST r0,0x06		// store bit 6 in T for testing
	BRTS is_one
	BRTC is_zero

is_zero:
	STD Z + 0x20 , r0
	RJMP end
is_one:
	LDI r17 , 5
	MUL r0 , r17
	ROR r0
	OUT 0x31 , r0
	OUT 0x31 , r1
	RJMP end
last_part:          // sp is equal to ramend (again, first comment)
	IN r0, 0X30
	SWAP r0
	LDI r17 , 0b11110111
	AND r0 , r17
	BST r0,0x06
	STD Z + 0x20 , r0         // Z = 0x90
	PUSH r0
	LDI r17 , 5
	MUL r0 , r17
	ROR r0
	PUSH r0
	PUSH r1
	IN r20,SPL
	IN r21,SPH   // final value of sp
	RJMP end
end: RJMP end
