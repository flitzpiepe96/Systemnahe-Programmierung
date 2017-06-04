org 00h
	ljmp main
org 03h				; INT0
	ljmp int0_handler
org 0bh
	ljmp timer_int_handler

org 10h
ACTIVE_PLAYER equ 20h
STRING_POS_ACTIVE_PLAYER equ 21h

main:
	mov STRING_POS_ACTIVE_PLAYER, #0Fh;set string position
	call irs_init
	call lcd_init			;initialize LCD
	call random_init
	;call timer_load_realworld_defaults
	call timer_load_simulator_defaults
	call timer_init

gamestart:
	acall waitForBuzzer

	; set active player based on random number
	call random_seed_from_timer
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

	; setup timer

	call random_next
	
	; Up to 30s random game time
	; 30000ms = 117 * 255 ms
	; yai, we can use the 8051's 8x8->16 multiplication!
	;mov A,#117
	;mov B,RANDOM_NUM
	;mul AB

	; In the simulator: 15 ticks max
	mov A,RANDOM_NUM
	anl A,#00001111b
	mov B,#0
	
	; Additionally: Minimum game length: 10s = 0x2710ms
	; using 16bit addition like a pleb
	;add A,#10h
	;mov R0,A ; R0 as temporary
	;mov A,B
	;addc A,#27h

	; In the simulator: 10 extra ticks
	; no 16bit addition necessary here
	add A,#10
	mov R0,A
	mov A,#0

	; now write the result to the timer
	mov TIMER_DEC_COUNTER,R0
	mov TIMER_DEC_COUNTER+1,A

	clr BUZZER

throwBomb:
	; exit game on timeout
	mov A,TIMER_DEC_COUNTER
	orl A,TIMER_DEC_COUNTER+1
	jz game_timeout

	; check for button press
	mov A,BUZZER
	cjne A, #1, throwBomb ; not pressed

	; pressed
	clr BUZZER
	
	acall toggleActivePlayer
	acall sendActivePlayerNumber
	ljmp throwBomb

game_timeout:
	; todo: game over screen, allow restart
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
include timers.asm

ende:
	jmp ende
	end