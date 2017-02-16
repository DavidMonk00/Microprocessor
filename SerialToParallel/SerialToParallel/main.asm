;
; SerialToParallel.asm
;
; Created: 27/01/2017 10:28:20
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
		; The main part of our program
		;
		jmp Main

Counter1:	
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
		rcall Counter1
		dec r17
		brne loop2
	pop r17
	ret

Counter3:
	push r17
	ldi r17, 0x08
	loop3:
		rcall Counter2
		dec r17
		brne loop3
	pop r17
	ret

Main:
	ldi r16, 0x55
	rcall SPI_MasterInit
	rcall SPI_MasterTransmit
	rcall Counter3
	ldi r16, 0xaa
	rcall SPI_MasterInit
	rcall SPI_MasterTransmit
	rcall Counter3
	//jmp Main
	ldi r16, 0xf0
	rcall SPI_MasterInit
	rcall SPI_MasterTransmit
	rcall Counter3
	ldi r16, 0x0f
	rcall SPI_MasterInit
	rcall SPI_MasterTransmit
	rcall Counter3
	jmp Main

SPI_MasterInit:
	ldi r17, (1<<DDB2)|(1<<DDB1)|(1<<DDB0)
	out ddrb, r17
	ldi r17, (1<<SPE)|(1<<MSTR)|(1<<SPR0)
	out SPCR, r17
	ret

SPI_MasterTransmit:
	out SPDR, r16

Wait_Transmit:
	sbis SPSR,SPIF
	rjmp Wait_Transmit
	ret




