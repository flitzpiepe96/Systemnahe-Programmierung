BUZZER_IR equ p3.2
BUZZER equ 40h

	ljmp IRS_init

org 03h				; INT0
	ljmp int0_handler

IRS_init:
	setb EA			;enable Interrupts
	setb EX0		;enable INT0
	setb IT0		;make INT0 edge triggered
	ret

int0_handler:
	mov BUZZER, #01h
	clr IE0
	reti	
