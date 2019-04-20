/*
 * q2.asm
 *
 *  Created: 3/25/2019 2:43:59 PM
 *   Author: Armaghan
 */

 .include "m16def.inc"
 .ORG 0
 .DEF counter = r24
 .DEF result = r16
 .DEF arr1 = r21
 .DEF arr2 = r22

 ;ldi r25 , 4     ; for writing in eeprom and checking inequality
 ;ldi r26 , 0x65  ; address

 ldi r20, HIGH(RAMEND)
 out SPH, r20
 ldi r20, LOW(RAMEND)
 out SPL,r20

 ldi r30 , 0x60         
 ldi r31 , 0x00    // load z
 ldi r28 , 0x80    // load y    
 ldi r29 , 0x00

 ldi counter , -10         
 ldi result , 1
 
 label1:
	;CALL EEPROM_WRITE
	CALL EEPROM_READ_1
	ADIW Z,1
	CALL EEPROM_READ_2
	ADIW Y,1
	CPSE arr1 , arr2
	LDI result , 0
	INC counter
	BRNE label1   // branch if Z is 0

 label2 : RJMP label2

 EEPROM_READ_1:
	sbic EECR,EEWE
	rjmp EEPROM_READ_1
	out EEARH, r31
	out EEARL, r30
	sbi EECR,EERE
	in arr1,EEDR
RETI

 EEPROM_READ_2:
	sbic EECR,EEWE
	rjmp EEPROM_READ_2
	out EEARH, r29
	out EEARL, r28
	sbi EECR,EERE
	in arr2,EEDR
 RETI

/*EEPROM_WRITE:           // the checking mentioned above
	sbic EECR,EEWE
	rjmp EEPROM_WRITE
	out EEARH, r31
	out EEARL, r26
	out EEDR, r25
	sbi EECR,EEMWE
	sbi EECR,EEWE
RETI */