; debug code
ORG 0h
jmp debug

; ------------------------
; Why so complicated?
;
; Our 12MHz chip has a timer frequency of 1MHz --> 1tick == 1us
; We want our game to last up to a minute, but even the 16bit counter
; can only count to ~65ms. Therefore we don't just use a timer, but
; on each timer overflow we decrement a counter, giving us a maximum
; time of about 16s for one 8bit counter and more than an hour when
; we use a second counter.
;
; So here comes the math: We want a 16bit counter that counts down
; millieconds, so we need the timer interrupt to fire every 1000us
; that's why we reset the timer to 0xFFFF-10000 = 0xFC17 every time
; --> see load_realworld_defaults
; by counting milliseconds, we have a range of up to a minute, which
; should exceed most people's attention span anyway

; Of course the whole thing is a bit moot since our simulator 
; is at least a factor 10k slower

; Timer ISR
ORG 0bh
call timer_int_handler
reti

ORG 20h

; -----------
; global variables
dseg at 30h;

; 16-bit number (LE) to load into timer register
timer_reload_val: ds 2

; 16-bit (LE) counter that will be decremented on each timer overflow,
; but never below 0. 
timer_dec_counter: ds 2

; 8-bit counter that will be incremented on each timer overflow,
; with wrap-around. Useful for... I don't know
; we don't remove it because who knows what would break
timer_inc_counter: ds 1


timerinit:
	; Subroutine to setup the timer

	; reset timer counter
	mov TL0,TIMER_RELOAD_VAL;
	mov TH0,TIMER_RELOAD_VAL+1;
	
	; intialize timer mode: timer 0 in 16 bit mode
	mov TMOD,#01h;
	setb TR0;

	; enable timer interrupt
	setb EA;
	setb ET0;

	ret;

timer_int_handler:	
	; timer interrupt handler
	mov TL0,TIMER_RELOAD_VAL;
	mov TH0,TIMER_RELOAD_VAL+1;

	mov A,TIMER_DEC_COUNTER
	jz timer_lo_zero
	dec TIMER_DEC_COUNTER
	jmp timer_hi_zero
timer_lo_zero:
	mov A,TIMER_DEC_COUNTER+1
	jz timer_hi_zero
	dec TIMER_DEC_COUNTER+1
	mov TIMER_DEC_COUNTER,#0FFh
timer_hi_zero:
	inc TIMER_INC_COUNTER

	ret

timer_load_realworld_defaults:
	; in the real world, we count milliseconds
	;0xFC17
	mov TIMER_RELOAD_VAL,#017h
	mov TIMER_RELOAD_VAL+1,#0FCh

	ret

timer_load_simulator_defaults:
	; in the simulator, we count in 100us intervals
	mov TIMER_RELOAD_VAL,#09Bh
	mov TIMER_RELOAD_VAL+1,#0FFh

	ret
debug:	
	; call initializer
	call timer_load_simulator_defaults
	
	mov TIMER_DEC_COUNTER,#10h
	mov TIMER_DEC_COUNTER+1,#01h
	call timerinit;

	; loop
	jmp $
	
