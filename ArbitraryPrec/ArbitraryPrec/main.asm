;
; ArbitraryPrec.asm
;
; Created: 03/02/2017 16:39:40
; Author : David
;

.org 0
rjmp Init

Init:
	; Stack pointer setup
	push	r16
	ldi		r16,	0x0f
	out		SPH,	r16
	ldi		r16,	0xff
	out		SPL,	r16
	;
	; RAMPZ setup
	ldi		r16,	0x00
	out		RAMPZ,	r16
	;
	; Port setup
	ldi r16, $FF		; 
	out DDRB , r16		; Port B Direction Register
	ldi r16, $FF		; Init value 
	out PORTB, r16		; Port B value
	;
	pop r16
	ldi		r24, 0x00
	rjmp Main

.def	temp			= r16
.def	integer_a		= r17
.def	integer_b		= r18
.def	integer_c		= r19
.def	integer_d		= r20
.def	carry			= r21
.def	i				= r22
.def	j				= r23
.def	carrybyte		= r3

.equ	args	= 0x0100
.equ	l		= 16
.equ	res		= args+(2*l)
.equ	data	= 0x0200

integer1:
.db	0xef, 0xbe,0xad,0xde,0xef, 0xbe,0xad,0xde,0xef, 0xbe,0xad,0xde,0xef, 0xbe,0xad,0xde
;.db		0xef,0xbe,0x00,0x00,0x00,0x00,0x00,0x00
integer2:
.db	0xef, 0xbe,0xad,0xde,0xef, 0xbe,0xad,0xde,0xef, 0xbe,0xad,0xde,0xef, 0xbe,0xad,0xde
;.db		0xef,0xbe,0x00,0x00,0x00,0x00,0x00,0x00

Main:
	com		r24
	out		portb, r24
	rcall	LoadData
	;rcall	_Add
	rcall	_Mul
	rjmp	Main

_Mul:
	push	XL							; Pushing registers
	push	XH							;
	push	temp						;
	push	carrybyte					;
	push	i							;
	push	j							;
	ldi		XL,		low(args+2*l)		; Clear memory allocated to result
	ldi		XH,		high(args+2*l)		;
	ldi		i,		2*l					;
	_MulInitMemory:						;
		ldi		temp,	0x00			;
		st		X+,		temp			;
		dec		i						;
		brne	_MulInitMemory			;

	ldi		XH,		high(args)			; Load High byte of address
	ldi		i,		0x00				; Initialise counters
	ldi		j,		0x00				;
	_Mulloop1:								
		ldi		XL,				low(args)	; Load low byte
		add		XL,				i			; Move address to correct location
		ld		integer_a,		X			; Load first number
		ldi		XL,				low(args)	;
		adiw	X,				l			;
		add		XL,				j			;
		ld		integer_b,		X			; Load second number
		ldi		XL,				low(args)	; Load existing byte at address 2*l + i + j
		adiw	X,				2*l			;
		add		XL,				j			;
		add		XL,				i			;
		ld		integer_c,		X			; 
		mul		integer_a,		integer_b	; Multiply two numbers
		add		r0,				integer_c	; Add existing value to lower byte
		brcc	_Mulloopstore				; Branch if no carry
		inc		r1							; Else incrment high byte
		_Mulloopstore:
		st		X+,				r0			; Store lower byte
		ld		integer_d,		X+			; Load address of high byte
		add		r1,				integer_d	; Add to high byte of result
		brcs	_Muladdcarry				; Branch if carry set
		rjmp	_Muladdcarryend
		_Muladdcarry:
			ld		integer_d,		X
			ldi		temp,			0x01
			add		integer_d,		temp
			st		X+,				integer_d
			brcs	_Muladdcarry
		_Muladdcarryend:
		ldi		XL,				low(args)	; Go to address of result
		adiw	X,				2*l			;
		add		XL,				j			;
		add		XL,				i			;
		inc		XL
		st		X,				r1
		inc		j
		cpi		j, l
		brne	_Mulloop1
		clr		j
		inc		i
		cpi		i, l
		brne	_Mulloop1
	pop		j
	pop		i
	pop		carrybyte
	pop		temp
	pop		XH
	pop		XL
	ret

_Add:
	push	XL
	push	XH
	push	temp
	push	i
	push	carry
	clc								; Clear carry flag
	ldi		XL,		low(args)
	ldi		XH,		high(args)
	ldi		i,		l
	_Addloop:
		ld		integer_a,		X	;Load parts of number
		adiw	X,				l
		ld		integer_b,		X
		adiw	X,				l
		sbrc	carry,			0	; Skip if bit in carry register is cleared
		sec
		adc		integer_a,		integer_b
		brcs	_AddloopCarry
		clr		carry
		_AddloopCont:
		st		X,				integer_a
		sbiw	X,				2*l - 1
		rjmp	_AddloopEnd
		_AddloopCarry:
			ldi		carry,	0x01
			rjmp	_AddloopCont
		_AddloopEnd:
		dec		i
		brne	_AddLoop
	ldi		XL,		low(res+l)
	ldi		XH,		high(res+l)
	sbrc	carry,			0
	sec
	brcs	_AddStoreCarry
	ldi		temp,		0x00
	st		X,		temp
	rjmp _AddEnd
	_ADDStoreCarry:
		ldi		temp,		0x01
		st		X,		temp		
	_AddEnd:
	pop		carry
	pop		i
	pop		temp
	pop		XH
	pop		XL
	ret

LoadData:
	push	ZL
	push	ZH
	push	XL
	push	XH
	push	temp
	push	r17
	ldi		ZL,		low(integer1*2)
	ldi		ZH,		high(integer1*2)
	ldi		XL,		low(data)
	ldi		XH,		high(data)
	ldi		temp,	l
	LoadDataloop1:
		lpm		r17,	Z+
		st		X+,		r17
		dec		temp
		brne	LoadDataloop1
	ldi		ZL,		low(integer2*2)
	ldi		ZH,		high(integer2*2)
	ldi		temp,	l
	LoadDataloop2:
		lpm		r17,	Z+
		st		X+,		r17
		dec		temp
		brne	LoadDataloop2
	pop		r17
	pop		temp
	pop		XH
	pop		XL
	pop		ZH
	pop		ZL 
	ret