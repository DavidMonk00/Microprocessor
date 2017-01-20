;
; FlipFlopTest.asm
;
; Created: 20/01/2017 09:41:49
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
   		;
		; Comparator Setup Code
		; set the Comparator Setup Registor to Disable Input capture and the comparator
		; 
		ldi r16,$80			; Comparator Disabled, Input Capture Disabled 
		out ACSR, r16		; 
   		;
		; Port B Setup Code
		; Set up PORTB (the LEDs on STK300) as outputs by setting the direction register
		; bits to $FF. Set the initial value to $00 (which turns on all the LEDs) 
		; 
		ldi r16, $FF		; 
		out DDRA , r16		; Port A Direction Register
		ldi r16, $00		; Init value 
		out PORTA, r16		; Port A value
		ldi r16, $FF		; 
		out DDRB , r16		; Port B Direction Register
		ldi r16, $FF		; Init value 
		out PORTB, r16		; Port B value
		ldi r16, $FF		; 
		out DDRC , r16		; Port B Direction Register
		ldi r16, $FF		; Init value 
		out PORTC, r16		; Port B value
   		;
		; Port B Setup Code
		; Set up PORTB (the LEDs on STK300) as outputs by setting the direction register
		; bits to $FF. Set the initial value to $00 (which turns on all the LEDs) 
		; 
		ldi r16, $00		; 
		out DDRE , r16		; Port B Direction Register
		ldi r16, $FF		; Init value 
		out PORTE, r16		; Port B value
   		;
		; Port D Setup Code
		; Setup PORTD (the switches on the STK300) as inputs by setting the direction register
		; bits to $00.  Set the initial value to $FF
		;  
		ldi r16, $00		; I/O: 
		out DDRD, r16		; Port D Direction Register
		ldi r16, $FF		; Init value 
		out PORTD, r16		; Port D value
		;
		; The main part of our program
		;
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

Main:
	jmp write
	loopa:
		in r18, pind
		cpi r18, 0xfe
		breq output
		cpi r18, 0xfd
		breq write
		cpi r18, 0xfb
		breq clear
		ldi r17, 0b00000010
		inc r17
		out portc, r17
		jmp loopb
	loopb:
		dec r17
		out portc, r17
		jmp loopa
	output:
		ldi r17, 0b00000000
		out portc, r17
		inc r17
		out portc, r17
		in r2, pine
		out portb, r2
		dec r17
		jmp loopa
	write:
		ldi r16, 0b10101010
		ldi r17, 0b00000010
		out portc, r17
		out porta, r16
		inc r17
		out portc, r17
		jmp loopa
	clear:
		ldi r16, 0x00
		ldi r17, 0b00000010
		ldi r19, 0xff
		out porte, r19
		out portb, r19
		out portc, r17
		out porta, r16
		inc r17
		out portc, r17
		jmp loopa
		


	jmp Main


