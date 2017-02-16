;
; EncSlave.asm
;
; Created: 10/02/2017 12:51:59
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
	; Extrernal SRAM
	ldi r16, 0xc0
	out MCUCR, r16
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
	rcall initDisp
	rcall clrDIS
	ldi r16, 0xaa
	clr r21
	rjmp main

.equ data = 0x0100
.equ cypher = 0x0200

main:
	rcall USARTReceive
	cpi r16, 0x02
	brne main_end
	rcall storemessage
	rcall generateCypher
	rcall displayMessage
	main_end:
		rjmp main

generateCypher:
	ldi r16, 0xaa
	ldi		YL,		low(cypher)		; Clear memory allocated to result
	ldi		YH,		high(cypher)
	ldi		XL,		low(data)		; Clear memory allocated to result
	ldi		XH,		high(data)
	generateCypher_loop:
		ld r0, X+
		rcall lfsr
		eor r0, r16
		st Y+, r0
		dec r17
		brne generateCypher_loop
	ldi r17, 0x04
	st Y, r17
	ret

storemessage:
	clr r17
	rcall USARTReceive
	cpi r16, 0x04
	breq storemessage_end
	ldi		YL,		low(data)		; Clear memory allocated to result
	ldi		YH,		high(data)
	storemessage_store:
		st	Y+, r16
		inc r17
		rcall USARTReceive
		cpi r16, 0x04
		breq storemessage_end
		rjmp storemessage_store
	storemessage_end:
		st	Y+, r16
		ret

displayMessage:
	push r16
	rcall clrDIS
	ldi		YL,		low(cypher)		; Clear memory allocated to result
	ldi		YH,		high(cypher)
	displayMessage_load:
		ld r16, Y+
		cpi r16, 0x04
		breq displayMessage_end
		sts 0xc000, r16
		rcall busyLCD
		rjmp displayMessage_load
	displayMessage_end:
		pop r16
		ret


USARTInit:
	sts UBRR1H, r17
	sts	UBRR1L, r16
	ldi r16, (1<<RXEN1)|(1<<TXEN1)
	sts UCSR1B, r16
	ret

USARTReceive:
	push r18
	push r19
	USARTReceive_start:
	lds r18, UCSR1A
	sbrs r18, RXC1
	rjmp USARTReceive_start
	lds r16, UDR1
	mov r19, r16
	com r19
	out PORTB, r19
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
	push r16
	ldi		r16, 0x01
	sts		0x8000, r16
	rcall	busyLCD
	pop r16
	ret

busyLCD:
	push r16
	busyLCDstart:
		lds		r16, 0x8000
		sbrc	r16, 7
		rjmp	busyLCDstart
	rcall	DEL100mus
	pop r16
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