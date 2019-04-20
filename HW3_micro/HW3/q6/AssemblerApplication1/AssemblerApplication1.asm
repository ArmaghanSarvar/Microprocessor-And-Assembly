/*
 * AssemblerApplication1.asm
 *
 *  Created: 3/26/2019 1:02:00 PM
 *   Author: Armaghan
 */ 
 .include "m16def.inc"
 .ORG 0
 .DEF counter = r24
 .DEF num2 = r16
 .DEF num1 = r17

 LDI r26 , 0b01110000         // load x
 LDI r27 , 0x00

 LDI counter , -10
 LDI r21 , 0
 LDI num1 , 0
 LDI num2 , 0

 ST X+ , num2
 LDI num2 , 1
 ST X+ , num2

 label1:
	MOV r21 , num2
	ADD num2 , num1
	ST X+ , num2
	MOV num1 , r21
	INC counter
	BRNE label1	

 label2 : RJMP label2
