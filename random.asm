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
	mov RANDOM_NUM,#42
	ret
