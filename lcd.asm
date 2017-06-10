LCD_data equ P2			;LCD Data port
LCD_D7   equ P2.7		;LCD D7/Busy Flag
LCD_rs   equ P1.0		;LCD Register Select
LCD_rw   equ P1.1		;LCD Read/Write
LCD_en   equ P1.2		;LCD Enable
CURSOR_POS equ 35h

P1_DEATH equ 30h
P2_DEATH equ 31h
STRING_POS_P1_DEATH equ 32h
STRING_POS_P2_DEATH equ 33h


lcd_init:
	mov STRING_POS_P1_DEATH, #0bh ;set string position P1
	mov STRING_POS_P2_DEATH, #13h ;set string position P2
	acall LCD_busy       	;Wait for LCD to process the command

	LCD_command #38h	;Function set: 2 Line, 8-bit, 5x7 dots
	LCD_command #0ch  	;Display on, without cursor
	LCD_command #01H  	;Clear LCD
	LCD_command #06H  	;Entry mode, auto increment with no shift

	LCD_setCursor #01h, #00h
	LCD_sendString BEGIN

	LCD_setCursor #02h, #00h
	LCD_sendString DEATH

	ret

lcd_busy:			;Wait until Busy-Flag is unset
	setb   LCD_D7		;Make D7th bit of LCD data port as i/p
	setb   LCD_en		;Make port pin as o/p
	clr    LCD_rs		;Select command register
	setb   LCD_rw		;we are reading
check:
	clr    LCD_en		;Enable H-> L
	setb   LCD_en
	mov A, LCD_data
	jb     LCD_D7,check	;read busy flag again and again till it becomes 0
	ret			;Return from busy routine

deathcount macro player
	local PLAYER2
	local END
	mov A, player
	cjne A, #01h, PLAYER2
	LCD_setCursor #02h, STRING_POS_P1_DEATH
	inc P1_DEATH
	mov A, P1_DEATH
	add A, #30h
	jmp END
player2:
	LCD_setCursor #02h, STRING_POS_P2_DEATH
	inc P2_DEATH
	mov A, P2_DEATH
	add A, #30h
end:
	LCD_sendChar A 
endm
	

lcd_command macro cmd
	mov   LCD_data, cmd	;Move the command to LCD port
	clr   LCD_rs		;Selected command register
	clr   LCD_rw		;We are writing in instruction register
	setb  LCD_en		;Enable H-> L
	clr   LCD_en
	acall LCD_busy		;Wait for LCD to process the command
endm

lcd_sendChar macro char		;call this macro like   LCD_sendChar #'A'
	mov   	LCD_data, char 	;Move the command to LCD port
	setb	LCD_rs		;Selected data register
	clr	LCD_rw		;We are writing
	setb	LCD_en		;Enable H-> L
	clr	LCD_en
	inc	CURSOR_POS	;save new cursor position
	acall	LCD_busy	;Wait for LCD to process the data
endm

lcd_sendString macro string
	local START		;define local macro variable
	local EXIT		;define local macro variable
	mov   dpl, #low(string)
	mov   dph, #high(string)
start:				;locale variables have to be in lowercase, idk why^^
	clr   a                 ;clear Accumulator for any previous data
	movc  a,@a+dptr         ;load the first character in accumulator
	jz    EXIT              ;go to exit if zero
	LCD_sendChar A		;send actual char
	inc   dptr              ;increment data pointer
	sjmp  START    ;jump back to send the next character
exit:				;locale variables have to be in lowercase, idk
endm

lcd_setCursor macro line, position
	local LINE2		;define local macro variable
	local END		;define local macro variable
	mov CURSOR_POS, position;save new cursor position
	mov A, line
	cjne A, #01h, LINE2	;if line != 01h jump to LINE2
	mov A, #80h		;startpoint for first line of LCD
	jmp END
line2:				;locale variables have to be in lowercase, idk why^^
	mov A, #0C0h		;startpoint for second line of LCD
end:				;locale variables have to be in lowercase, idk why^^
	add A, position
	LCD_command A
endm

lcd_clearToEndOfLine:
	mov A, CURSOR_POS	;load current cursor positon
	cjne A, #14h, blank	;A!=20
	ret
blank:
	lcd_sendChar #' '
	jmp lcd_clearToEndOfLine

;strings
cseg
BEGIN:		DB 'Hit BUZZER to start!', 0
DEATH:		DB 'DEATH  P1: 0   P2: 0', 0
ACTIVE:		DB 'Active Player: ',0
BOOM:		DB 'BOOM! Looser: P', 0

