dseg at 40h
; A random 8bit number. This is also the seed for
; the random_next function, which has no state
; beyond the last calculated random number.
RANDOM_NUM: ds 1

; stolen from Lausen's moodle room

; We don't know what kind of PRNG this is,
; Probably not a very good one. If we have too much
; time left, we should replace this with our own
; implementation of a standard MWC or LFSR-based
; PRNG to have an actual learning experience here.

cseg
; Writes random number in RANDOM_NUM,
; uses last one as seed.
; 8-bit galois lsfr implemented according to wikipedia
random_next:
	mov A, RANDOM_NUM

	clr C
	rrc A ; rotate right
	jnc random_skipmask

	; apply xor mask for x^8+x^6+x^5+x^4+1
	xrl A,#10111000b
random_skipmask:
	mov RANDOM_NUM,A
	
	ret
	
random_init:
	; yeah this is really bad
	; but hopefully someone will call
	; random_seed_from_timer sometime soon
	mov RANDOM_NUM,#42

	; setup timer 1 for random seed values
	; WTF: we can't set M11/M01 directly, even though
	; that does work with M10/M00. We could use Timer0,
	; but we'd rather reserve it for the countdown
	orl TMOD,#00100000b
	anl TMOD,#11101111b
	setb TR1
	
	ret

random_seed_from_timer:
	mov A,TL1
	; our LSFR won't work if all bits are zero
	jnz random_seed_from_timer_nonzero
	mov A,#0FFh
random_seed_from_timer_nonzero:
	mov RANDOM_NUM,A
	ret