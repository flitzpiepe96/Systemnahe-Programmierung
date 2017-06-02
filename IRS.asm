BUZZER_IR equ p3.2
BUZZER equ B.0

IRS_init:
	setb EA			;enable Interrupts
	setb EX0		;enable INT0
	setb IT0		;make INT0 edge triggered
	ret

int0_handler:
	setb BUZZER		;set BUZZER
	clr IE0
	reti	
