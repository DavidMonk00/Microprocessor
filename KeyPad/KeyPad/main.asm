;
; KeyPad.asm
;
; Created: 30/01/2017 11:27:31
; Author : dm2614
;

		.ORG	0 ; Resets memory location counter
		;
		;
		; The first instruction jumps to our initialization routine
		;
         rjmp Init


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
	sbrc	r23, 0
	cbr		r23, 0x1
	rcall	getKeyPadValue
	rcall	mess1Out
	rcall	bigDel
	;rcall	clrDIS
	rjmp	Main

getKeyPadValue:
	rcall	DEL50mus
	clr		r3
	clr		r4
	push	r16
	clr		r16
	out		SFIOR, r16	; set PUD to zero
	ldi		r16, 0x0f
	out		DDRE, r16
	ldi		r16, 0xf0
	out		PORTE, r16
	rcall	DEL50mus
	in		r3, PINE
	rcall	DEL50mus
	ldi		r16, 0xf0
	out		DDRE, r16
	ldi		r16, 0x0f
	out		PORTE, r16
	rcall	DEL50mus
	in		r4, PINE
	add		r3, r4
	com		r3
	breq	unpressedReturn
	
	mov		r5, r3
	ldi		r19, 0x00
	ldi		r20, 0x00
	looplow:
		mov		r21, r5
		andi	r21, 0x01
		breq	shiftlow
		swap	r3
		rjmp	loophigh
	shiftlow:
		lsr		r5
		inc		r19
		rjmp	looplow
	loophigh:
		mov		r21, r3
		andi	r21,0x01
		breq	shifthigh
		add		r19,r20
		pop r16
		ret
	shifthigh:
		lsr		r3
		ldi		r22, 0x04
		add		r20,r22
		rjmp	loophigh
	unpressedReturn:
		ldi		r19, 0x10
		pop		r16
		ret
Mess1:
.db '1','2','3','A','4','5','6','B','7','8','9','C','*','0','#','D',' '

mess1Out:
	ldi ZH, HIGH(2*Mess1)
	ldi ZL, LOW(2*Mess1)
	inc r19
	cpi	r19, 0x11
	breq mess1OutEnd
	mess1More:
		lpm		r0, Z+
		mov		r17, r0
		rcall	busyLCD
		dec		r19
		breq	mess1End
		rjmp	mess1More
	mess1End:
		sts		0xc000, r17
		rcall	busyLCD
		ret
	mess1OutEnd:
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
