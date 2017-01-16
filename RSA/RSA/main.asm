;
; RSA.asm
;
; Created: 16/01/2017 15:08:51
; Author : dm2614
;

	.ORG	0 ; Resets memory location counter
	;
	;
	; The first instruction jumps to our initialization routine
	;
    rjmp Init


Init:                
   	;  Setup the Stack Pointer to point at the end of SRAM
	;  Put $0FFF in the 1 word SPH:SPL register pair
	 
	ldi r16, $0F		; Stack Pointer Setup 
	out SPH,r16			; Stack Pointer High Byte 
	ldi r16, $FF		; Stack Pointer Setup 
	out SPL,r16			; Stack Pointer Low Byte 
   	
	; RAMPZ Setup Code
	; Setup the RAMPZ so we are accessing the lower 64K words of program memory
	
	ldi  r16, $00		; 1 = EPLM acts on upper 64K
	out RAMPZ, r16		; 0 = EPLM acts on lower 64K
   	
	; Comparator Setup Code
	; set the Comparator Setup Registor to Disable Input capture and the comparator
	 
	ldi r16,$80			; Comparator Disabled, Input Capture Disabled 
	out ACSR, r16		; 
   	
	; Port B Setup Code
	; Set up PORTB (the LEDs on STK300) as outputs by setting the direction register
	; bits to $FF. Set the initial value to $00 (which turns on all the LEDs) 
	 
	ldi r16, $FF		; 
	out DDRA , r16		; Port B Direction Register
	ldi r16, $FF		; Init value 
	out PORTA, r16		; Port B value
   	
	; Port B Setup Code
	; Set up PORTB (the LEDs on STK300) as outputs by setting the direction register
	; bits to $FF. Set the initial value to $00 (which turns on all the LEDs) 
	 
	ldi r16, $FF		; 
	out DDRB , r16		; Port B Direction Register
	ldi r16, $FF		; Init value 
	out PORTB, r16		; Port B value
   	
	; Port D Setup Code
	; Setup PORTD (the switches on the STK300) as inputs by setting the direction register
	; bits to $00.  Set the initial value to $FF
	  
	ldi r16, $00		; I/O: 
	out DDRD, r16		; Port D Direction Register
	ldi r16, $FF		; Init value 
	out PORTD, r16		; Port D value
	
	; The main part of our program
	; Subroutine variables:
	.equ modargs = 0x0100
	.equ modreturn = 0x0102
	.equ primearg = 0x0103
	.equ primeret = 0x0104
	jmp Main

Counter:	
	push r17
	ldi r17, 0xff
	loop1:
		dec r17
		brne loop1
	pop r17
	ret

Counter2:
	push r17
	ldi r17, 0xff
	loop2:
		rcall Counter
		dec r17
		brne loop2
	pop r17
	ret

Counter3:
	push r17
	ldi r17, 0x0a
	loop3:
		rcall Counter2
		dec r17
		brne loop3
	pop r17
	ret

Modulo:
	
	ldi XL, low(modargs)
	ldi XH, high(modargs)
	ld r2, X+
	ld r3, X
	push r16
	push r17
	ldi r16, 0x00
	ldi r17, 0x00
	loopDivide:
		inc r16
		sub r2, r3
		brsh loopDivide
	dec r16
	add r2, r3
	ldi XL, low(modreturn)
	ldi XH, high(modreturn)
	st X, r2
	pop r17
	pop r16
	ret

PrimeGen:
	ldi XL, low(primearg)
	ldi XH, high(primearg)
	ld r16, X 
	ldi r17, 0x01
	primeloop:
		inc r17
		cp	r16,r17
		breq primetrue
		ldi XL, low(modargs)
		ldi XH, high(modargs)
		st X+, r16
		st X, r17
		rcall Modulo
		ldi XL, low(modreturn)
		ldi XH, high(modreturn)
		ld r18, X+
		cpi r18, 0x00
		breq primefalse
		brne primeloop
	
	primetrue:
		ldi XL, low(primeret)
		ldi XH, high(primeret)
		ldi r18, 0x01
		st X, r18
		ret
	primefalse:
		ldi XL, low(primeret)
		ldi XH, high(primeret)
		ldi r18, 0x00
		st X, r18
		ret

Main:
	ldi r20, 0xfb

	ldi XL, low(primearg)
	ldi XH, high(primearg)
	st X, r20
	rcall PrimeGen
	ldi XL, low(primeret)
	ldi XH, high(primeret)
	ld r2, X
	out porta, r0
	com r0
	out portb, r2
	jmp Main


