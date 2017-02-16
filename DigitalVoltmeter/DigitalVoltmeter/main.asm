;
; DigitalVoltmeter.asm
;
; Created: 02/02/2017 14:31:06
; Author : dm2614
;


; Replace with your application code

.def TempReg	= r16
.def ADCChannel	= r18
.def ADCDL		= r19
.def ADCDH		= r20
.def dispval	= r17

Init:                
   		;
		;  Setup the Stack Pointer to point at the end of SRAM
		;  Put $0FFF in the 1 word SPH:SPL register pair
		; 
		ldi r16, $0F		; Stack Pointer Setup 
		out SPH,r16			; Stack Pointer High Byte 
		ldi r16, $FF		; Stack Pointer Setup 
		out SPL,r16			; Stack Pointer Low Byte 
   		;
		; RAMPZ Setup Code
		; Setup the RAMPZ so we are accessing the lower 64K words of program memory
		;
		ldi  r16, $00		; 1 = EPLM acts on upper 64K
		out RAMPZ, r16		; 0 = EPLM acts on lower 64K
		; Setup External SRAM
		ldi r16, 0xc0
		out MCUCR, r16
		;
		; Port setup
		;
		ldi		r16, 0xff
		out		DDRA, r16
		ldi		r16, 0x00
		out		PORTA, r16
		ldi		r16, 0xff
		out		DDRB, r16
		ldi		r16, 0xff
		out		PORTB, r16
		ldi		r16, 0x00
		out		PORTC, r16
		;
		clr		r23
		sbr		r23, 1
		jmp		Main

Main:
	sbrc	r23, 0
	rcall	initDisp
	rcall	ADCInit
	rcall	ADCSel
	sbrc	r23, 0
	cbr		r23, 0x1

	rcall	DCATrig
	com		r19
	out		portb, r19
	com		r19
	rcall	displayDecimal
	rcall	bigDel
	rcall	clrDIS
	rjmp	Main

ADCInit:
	push	TempReg
	ldi		TempReg, 0x83
	out		ADCSR, TempReg
	pop		TempReg
	ret
ADCSel:
	push	ADCChannel
	clr		ADCChannel
	out		ADMUX, ADCChannel
	pop		ADCChannel
	ret
DCATrig:
	sbi		ADCSR, 6
	ADCCLR:
		sbis	ADCSR, 4
		rjmp	ADCCLR
		sbi		ADCSR, 4
		in		ADCDL, ADCL
		in		ADCDH, ADCH
	ret

dispDec:
	ldi		r21, 0x30
	add		dispval, r21
dispChar:
	push	TempReg
	sts		0xc000, dispval
	rcall	busyLCD
	pop		TempReg
	ret

displayDecimal:
	mov		dispval,	ADCDH
	rcall	dispDec
	ldi		dispval,	'.'
	rcall	dispChar
	ldi		TempReg,	10
	mul		ADCDL,		TempReg
	mov		dispval,	r1
	rcall	dispDec
	mul		r0,			TempReg
	mov		dispval,	r1
	rcall	dispDec
	mul		r0,			TempReg
	mov		dispval,	r1
	rcall	dispDec
	ldi		dispval,	'V'
	rcall	dispChar
	ret

initDisp:
	rcall	DEL15ms
	ldi		r16, 0x30
	sts		0x8000, r16
	rcall	DEL4P1ms
	sts		0x8000, r16
	rcall	DEL100mus
	sts		0x8000, r16
	rcall	busyLCD
	ldi		r16, 0x3f
	sts		0x8000, r16
	rcall	busyLCD
	ldi		r16, 0x08
	sts		0x8000, r16
	rcall	busyLCD
	ldi		r16, 0x01
	sts		0x8000, r16
	rcall	busyLCD
	ldi		r16, 0x38
	sts		0x8000, r16
	rcall	busyLCD
	ldi		r16, 0x0e
	sts		0x8000, r16
	rcall	busyLCD
	ldi		r16, 0x06
	sts		0x8000, r16
	rcall	busyLCD
	clr		r16
	ret

clrDIS:
	ldi		r16, 0x01
	sts		0x8000, r16
	rcall	busyLCD
	ret

busyLCD:
	lds		r16, 0x8000
	sbrc	r16, 7
	rjmp	busyLCD
	rcall	DEL100mus
	ret

BigDEL:
             rcall Del49ms
             rcall Del49ms
             rcall Del49ms
             rcall Del49ms
             rcall Del49ms
             ret
;
DEL15ms:
;
; This is a 15 msec delay routine. Each cycle costs
; rcall           -> 3 CC
; ret              -> 4 CC
; 2*LDI        -> 2 CC 
; SBIW         -> 2 CC * 19997
; BRNE        -> 1/2 CC * 19997
; 

            LDI XH, HIGH(19997)
            LDI XL, LOW (19997)
COUNT:  
            SBIW XL, 1
            BRNE COUNT
            RET
;
DEL4P1ms:
	LDI XH, HIGH(5464)
    LDI XL, LOW (5464)
	COUNT1:
		SBIW XL, 1
        BRNE COUNT1
	RET 
;
DEL100mus:
    LDI XH, HIGH(131)
    LDI XL, LOW (131)
	COUNT2:
		SBIW XL, 1
        BRNE COUNT2
	RET

DEL50mus:
    LDI XH, HIGH(65)
    LDI XL, LOW (65)
	COUNT4:
		SBIW XL, 1
		BRNE COUNT4
    RET  
;
DEL49ms:
	LDI XH, HIGH(65535)
    LDI XL, LOW (65535)
	COUNT3:
		SBIW XL, 1
		BRNE COUNT3
    RET