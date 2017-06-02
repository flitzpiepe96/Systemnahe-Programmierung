org 0h
jmp debug


dseg at 50h

; A random 8bit number. This is also the seed for
; the random_next function, which has no state
; beyond the last calculated random number.
RANDOM_NUM: ds 1


org 20h

; stolen from Lausen's moodle room

; We don't know what kind of PRNG this is,
; Probably not a very good one. If we have too much
; time left, we should replace this with our own
; implementation of a standard MWC or LFSR-based
; PRNG to have an actual learning experience here.

; Writes random number in RANDOM_NUM,
; uses last one as seed.
random_next:
	mov	A, RANDOM_NUM
	jnz	random_2
	cpl	A
	mov	RANDOM_NUM, A
random_2:
	anl	a, #10111000b
	mov	C, P
	mov	A, RANDOM_NUM
	rlc	A
	mov	RANDOM_NUM, A
	ret

debug:
	; random seed
	mov RANDOM_NUM,#42

	; generate some random numbers
gen:	call random_next
	jmp gen