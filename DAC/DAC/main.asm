;
; DAC.asm
;
; Created: 03/02/2017 10:43:36
; Author : dm2614
;


; Replace with your application code
Init:
    ldi		r16, 0xff
	out		DDRA, r16
	ldi		r16, 0x00
	out		PORTA, r16
	ldi		r16, 0x02
	ldi		ZH,high(2*data)
Main:
	ldi		r17, 0x10
	ldi		ZL, low(2*data)
	loop:
		lpm		r16,Z+
		out		porta, r16
		;rcall	del50mus
		dec		r17
		brne	loop
	rjmp	Main

Reset:
	ldi r16,	0xff

data:
.db 0x80,0x20,0x08,0x04,0x00,0x00,0x04,0x08,0x20,0x80,0xe0,0xf8,0xfa,0xff,0xff,0xfa,0xf8,0xe0

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