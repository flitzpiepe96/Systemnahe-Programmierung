org 00h
	ljmp main
org 03h				; INT0
	ljmp int0_handler

org 100h
ACTIVE_PLAYER equ 20h
STRING_POS_ACTIVE_PLAYER equ 21h

main:
	mov STRING_POS_ACTIVE_PLAYER, #0Fh;set string position
	call irs_init
	call lcd_init			;initialize LCD
	call random_init

gamestart:
	acall waitForBuzzer

	; set active player based on random number
	call random_next
	mov A,RANDOM_NUM
	
	mov ACTIVE_PLAYER, #01h
	jb A.0,gamestart_afterplayer
	mov ACTIVE_PLAYER, #02
gamestart_afterplayer:
	
	;send Active Player to LCD
	lcd_setCursor #01h, #00h
	lcd_sendString ACTIVE	
	acall sendActivePlayerNumber
	acall lcd_clearToEndOfLine

throwBomb:
	acall waitForBuzzer
	acall toggleActivePlayer
	acall sendActivePlayerNumber
	ljmp throwBomb

	ljmp ende

waitForBuzzer:
	clr BUZZER			;reset BUZZER
loopBuzzer:
	mov A, BUZZER			;load BUZZER
	cjne A, #01h, loopBuzzer	;wait until BUZZER is set
	ret

toggleActivePlayer:
	mov A, ACTIVE_PLAYER		;load active player
	cjne A, #01, player2		;if not player 1 jump to...
	inc ACTIVE_PLAYER		
	ret
player2:
	dec ACTIVE_PLAYER
	ret

sendActivePlayerNumber:
	lcd_setCursor #01h, STRING_POS_ACTIVE_PLAYER
	mov A, ACTIVE_PLAYER	;load active player
	add A, #30h		;convert to number representation
	lcd_sendChar A
	ret

include lcd.asm
include IRS.asm
include random.asm

ende:
	jmp ende
	end