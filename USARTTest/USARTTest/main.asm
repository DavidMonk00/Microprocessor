;
; USARTTest.asm
;
; Created: 09/02/2017 14:48:05
; Author : dm2614
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
	ldi r16, $00		; I/O: 
	out DDRD, r16		; Port D Direction Register
	ldi r16, $FF		; Init value 
	out PORTD, r16	
	;
	ldi		r16,	0x9f
	ldi		r17,	0x01
	rcall	USARTInit
	rcall	initDisp
	ldi		r16, 0xaa
	clr		r21
	rjmp	main

main:
	;rcall	bigdel
	loop:
		rcall bigdel
		in	r20, pind
		cpi r20,0xff
		brne loop
	rcall	USARTTransmit
	rcall lfsr
	rjmp main

USARTInit:
	sts UBRR1H, r17
	sts	UBRR1L, r16
	ldi r16, (1<<RXEN1)|(1<<TXEN1)
	sts UCSR1B, r16
	ret

USARTTransmit:
	push r18
	push r19
	lds	r18, UCSR1A
	sbrs r18, UDRE1
	rjmp USARTTransmit
	sts	UDR1, r16
	mov r19, r16
	com r19
	out PORTB, r19
	pop r19
	pop r18
	ret

USARTReceive:
	push r18
	push r19
	lds r18, UCSR1A
	sbrs r18, RXC1
	rjmp USARTReceive
	rcall clrDIS
	lds r16, UDR1
	mov r19, r16
	com r19
	out PORTB, r19
	sts 0xc000, r16
	rcall busyLCD
	pop r19
	pop r18
	ret

lfsr:
	push r19
	mov r2, r16
	ldi r19, 0x01
	mov r4, r19
	mov r3, r16
	lsr r3
	mov r5, r3
	lsr r3
	eor r2, r3
	lsr r3
	eor r2, r3
	lsr	r3
	eor r2, r3
	and r2, r4
	ldi r19, 0x07
	lfsr_loop4:
		lsl r2
		dec r19
		brne lfsr_loop4
	or r5,r2
	mov r16,r5
	pop r19
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