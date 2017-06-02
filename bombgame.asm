ACTIVE_PLAYER equ 20h

org 00h
	ljmp main

org 100h
main:
	call irs_init
	call lcd_init		;initialize LCD


	ljmp ende

include lcd.asm
include IRS.asm

ende:
	jmp ende
	end