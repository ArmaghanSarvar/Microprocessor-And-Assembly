.include "m16def.inc"

.equ LCD_RS	= 1
.equ LCD_RW	= 2
.equ LCD_E	= 3

.def a0 = R20
.def a1 = R21
.def a2 = R22
.def a3 = R23
.def a4 = R24
.def counter = R25

.def LBoundVoltageL = R3
.def LBoundVoltageH = R4
.def UBoundVoltageL = R5
.def UBoundVoltageH = R6

.def temp	= R16
.def argument= R17		;argument for calling subroutines
.def return	= R18		;return value from subroutines

 
 //  humidity percentage calculation
 
.def divider = R16
.def dividendL = R17
.def dividendH = R18
.def division_counter = R19

 .org 0
	JMP reset

.org 0x01C
	JMP ADC_routine

reset:
 ldi r16, HIGH(RAMEND);
 out SPH, R16
 ldi R16, LOW(RAMEND)
 out SPL, R16
 ldi counter, 0
 ldi r16 , (1<<PD4)
 out DDRD , r16
 rcall	LCD_init

 start:
	sbi DDRD, 4
	ldi r16, (1 << ADEN)|(1 << ADIE)|(1 << ADPS2)|(1 << ADPS1)|(1 << ADPS0)
	out ADCSRA, r16
	// read ADC2
	LDI R16, 0b01000010
	OUT ADMUX, R16
	SBI ADCSRA, ADSC
	sei

	LOOP1 : 
		cpi counter, 1
		breq select_adc2
		cpi counter, 2
		breq select_adc1
		 //sleep mode
		in R16, MCUCR
		LDI R16, (1 << SM0)|(1 << SE)
		out MCUCR, R16
		sleep
	rjmp LOOP1
		
	select_adc2:
		sbi ADMUX, MUX0
		sbi ADCSRA, ADSC
	rjmp loop1

	select_adc1:
		cbi ADMUX, MUX1
		//free runner mode
		sbi ADCSRA, ADATE
		sbi ADCSRA, ADSC
	rjmp loop1

ADC_routine:
	in R16, MCUCR
	CBR R16, SE
	OUT MCUCR, R16
	//Read lower bound voltage
	cpi counter, 0 
	breq read_lower_bound_voltage
	read1:
	//Read upper bound voltage
	cpi counter, 1
	breq read_upper_bound_voltage
	read2:
	cpi counter, 3
	in R16, SREG
	sbrs r16, 1
	inc counter

	cpi counter, 3
	breq humidity_measure
	
	done_measuring:
	RETI

DELAY:
	LDI R21, 0X01
DELAY2:
	LDI R22, 0xff
DELAY3:
	LDI R23, 0Xff
LOOP: DEC R23
	BRNE LOOP
	DEC R22
	BRNE DELAY3
	DEC R21
	BRNE DELAY2
	RETI

humidity_measure:
	IN R20, ADCL
	IN R21, ADCH

	call is_valid_humidity
	// if between 30% and 70%, turn LED1 on 

	subi r20, 197
	sbci r21, 0
	mov dividendH, r21
	mov dividendL, r20
	call division
	mov a0, division_counter
	ldi a1, 0
	ldi	argument, 0x01		
	rcall	LCD_command
	call binTobcd
	call delay	
rjmp done_measuring

read_lower_bound_voltage:
	IN R20, ADCL
	IN R21, ADCH
	MOV R3, R20;
	MOV R4, R21
	call binTobcd
	call delay
rjmp read1

read_upper_bound_voltage:
	IN R20, ADCL
	IN R21, ADCH
	MOV R5, R20;
	MOV R6, R21
	call binTobcd
	call delay

rjmp read2

comp_upperBound_voltageL:
	cp r20,UBoundVoltageL 
	brlo next
	breq make_on
	brsh make_off
	rjmp next

comp_lowerBound_voltageL:
	cp r20,LBoundVoltageL 
	brlo make_off
	brsh make_on
	rjmp final

is_valid_humidity:
	cp r21,UBoundVoltageH 
	brlo next
	breq comp_upperBound_voltageL
	brsh make_off
	next:
	cp r21,LBoundVoltageH 
	brlo make_off
	breq comp_lowerBound_voltageL
	brsh make_on

	final:
	ret

make_off:
	cbi PORTD, 4
	rjmp final

make_on:
	sbi PORTD, 4
	rjmp final
	
division:
	ldi division_counter, 0
	ldi divider, 6

	divide_low:
	mul divider, division_counter
	inc division_counter
	cpc r0, dividendL
	brsh divide2
	brlo divide_low

	divide2:
	dec division_counter
	divide_high:
	mul divider, division_counter
	inc division_counter
	cpc r1, dividendh
	brsh divide_low2
	brlo divide_high
	
	divide3:
	dec division_counter
	divide_low2:
	mul divider, division_counter
	inc division_counter
	cpc r0, dividendL
	brsh exit_divide
	brlo divide_low2

	exit_divide:
	dec division_counter
	dec division_counter
	ret

binTobcd:
        ldi a4, -1 + '0'
_bi1:   inc a4
        subi a0, low(10000)
        sbci a1, high(10000)
        brcc _bi1

        ldi a3, 10 + '0'
_bi2:   dec a3
        subi a0, low(-1000)
        sbci a1, high(-1000)
        brcs _bi2

		mov	argument, a3	
		rcall	LCD_putchar

        ldi a2, -1 + '0'
_bi3:   inc a2
        subi a0, low(100)
        sbci a1, high(100)
        brcc _bi3

		mov	argument, a2	
		rcall	LCD_putchar

        ldi a1, 10 + '0'
_bi4:   dec a1
        subi a0, -10
        brcs _bi4
        subi a0, -'0'
		mov	argument, a1	
		rcall	LCD_putchar

		mov	argument, a0	
		rcall	LCD_putchar
        ret


///////////////////////////////////////////////

lcd_command8:	;used for init (we need some 8-bit commands to switch to 4-bit mode!)
	in	temp, DDRC		;we need to set the high nibble of DDRD while leaving
					;the other bits untouched. Using temp for that.
	sbr	temp, 0b11110000	;set high nibble in temp
	out	DDRC, temp		;write value to DDRD again
	in	temp, PortC		;then get the port value
	cbr	temp, 0b11110000	;and clear the data bits
	cbr	argument, 0b00001111	;then clear the low nibble of the argument
					;so that no control line bits are overwritten
	or	temp, argument		;then set the data bits (from the argument) in the
					;Port value
	out	PortC, temp		;and write the port value.
	sbi	PortC, LCD_E		;now strobe E
	nop
	nop
	nop
	cbi	PortC, LCD_E
	in	temp, DDRC		;get DDRD to make the data lines input again
	cbr	temp, 0b11110000	;clear data line direction bits
	out	DDRC, temp		;and write to DDRD
ret

lcd_putchar:
	push	argument		;save the argmuent (it's destroyed in between)
	in	temp, DDRC		;get data direction bits
	sbr	temp, 0b11110000	;set the data lines to output
	out	DDRC, temp		;write value to DDRD
	in	temp, PortC		;then get the data from PortD
	cbr	temp, 0b11111110	;clear ALL LCD lines (data and control!)
	cbr	argument, 0b00001111	;we have to write the high nibble of our argument first
					;so mask off the low nibble
	or	temp, argument		;now set the argument bits in the Port value
	out	PortC, temp		;and write the port value
	sbi	PortC, LCD_RS		;now take RS high for LCD char data register access
	sbi	PortC, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PortC, LCD_E
	pop	argument		;restore the argument, we need the low nibble now...
	cbr	temp, 0b11110000	;clear the data bits of our port value
	swap	argument		;we want to write the LOW nibble of the argument to
					;the LCD data lines, which are the HIGH port nibble!
	cbr	argument, 0b00001111	;clear unused bits in argument
	or	temp, argument		;and set the required argument bits in the port value
	out	PortC, temp		;write data to port
	sbi	PortC, LCD_RS		;again, set RS
	sbi	PortC, LCD_E		;strobe Enable
	nop
	nop
	nop
	cbi	PortC, LCD_E
	cbi	PortC, LCD_RS
	in	temp, DDRC
	cbr	temp, 0b11110000	;data lines are input again
	out	DDRC, temp
ret

lcd_command:	;same as LCD_putchar, but with RS low!
	push	argument
	in	temp, DDRC
	sbr	temp, 0b11110000
	out	DDRC, temp
	in	temp, PortC
	cbr	temp, 0b11111110
	cbr	argument, 0b00001111
	or	temp, argument

	out	PortC, temp
	sbi	PortC, LCD_E
	nop
	nop
	nop
	cbi	PortC, LCD_E
	pop	argument
	cbr	temp, 0b11110000
	swap	argument
	cbr	argument, 0b00001111
	or	temp, argument
	out	PortC, temp
	sbi	PortC, LCD_E
	nop
	nop
	nop
	cbi	PortC, LCD_E
	in	temp, DDRC
	cbr	temp, 0b11110000
	out	DDRC, temp
ret

LCD_getchar:
	in	temp, DDRC		;make sure the data lines are inputs
	andi	temp, 0b00001111	;so clear their DDR bits
	out	DDRC, temp
	sbi	PortC, LCD_RS		;we want to access the char data register, so RS high
	sbi	PortC, LCD_RW		;we also want to read from the LCD -> RW high
	sbi	PortC, LCD_E		;while E is high
	nop
	in	temp, PinC		;we need to fetch the HIGH nibble
	andi	temp, 0b11110000	;mask off the control line data
	mov	return, temp		;and copy the HIGH nibble to return
	cbi	PortC, LCD_E		;now take E low again
	nop				;wait a bit before strobing E again
	nop	
	sbi	PortC, LCD_E		;same as above, now we're reading the low nibble
	nop
	in	temp, PinC		;get the data
	andi	temp, 0b11110000	;and again mask off the control line bits
	swap	temp			;temp HIGH nibble contains data LOW nibble! so swap
	or	return, temp		;and combine with previously read high nibble
	cbi	PortC, LCD_E		;take all control lines low again
	cbi	PortC, LCD_RS
	cbi	PortC, LCD_RW
ret					;the character read from the LCD is now in return

LCD_getaddr:	;works just like LCD_getchar, but with RS low, return.7 is the busy flag
	in	temp, DDRC
	andi	temp, 0b00001111
	out	DDRC, temp
	cbi	PortC, LCD_RS
	sbi	PortC, LCD_RW
	sbi	PortC, LCD_E
	nop
	in	temp, PinC
	andi	temp, 0b11110000
	mov	return, temp
	cbi	PortC, LCD_E
	nop
	nop
	sbi	PortC, LCD_E
	nop
	in	temp, PinC
	andi	temp, 0b11110000
	swap	temp
	or	return, temp
	cbi	PortC, LCD_E
	cbi	PortC, LCD_RW
ret

LCD_wait:				;read address and busy flag until busy flag cleared
	rcall	LCD_getaddr
	andi	return, 0x80
	brne	LCD_wait
	ret


LCD_delay:
	clr	r2
	LCD_delay_outer:
	clr	r3
		LCD_delay_inner:
		dec	r3
		brne	LCD_delay_inner
	dec	r2
	brne	LCD_delay_outer
ret

LCD_init:
	ldi	temp, 0b00001110	;control lines are output, rest is input
	out	DDRC, temp
	
	rcall	LCD_delay		;first, we'll tell the LCD that we want to use it
	ldi	argument, 0x20		;in 4-bit mode.
	rcall	LCD_command8		;LCD is still in 8-BIT MODE while writing this command!!!

	rcall	LCD_wait
	ldi	argument, 0x28		;NOW: 2 lines, 5*7 font, 4-BIT MODE!
	rcall	LCD_command		;
	
	rcall	LCD_wait
	ldi	argument, 0x0F		;now proceed as usual: Display on, cursor on, blinking
	rcall	LCD_command
	
	rcall	LCD_wait
	ldi	argument, 0x01		;clear display, cursor -> home
	rcall	LCD_command
	
	rcall	LCD_wait
	ldi	argument, 0x06		;auto-inc cursor
	rcall	LCD_command
ret

