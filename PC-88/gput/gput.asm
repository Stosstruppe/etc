;z80asm -b -l gput.asm

dst	equ	$bff0
src	equ	$bff2

	org	$bf00 - 4
	dw	Lstart
	dw	Lend
Lstart	equ	$

; call movvm(dst,src)
	push	de		; src
	ld	de, dst
	ldi
	ldi
	pop	hl
	ld	c, $5c
	di
L11:
	out	(c), a
	ld	a, $5f
	cp	c
	jr	z, L19
	push	bc
	ld	de, (dst)	; dst
	ld	bc, 16
	ldir
	pop	bc
	inc	c
	jp	L11
L19:
	ei
	ret

; call movvv(dst,src)
	push	de		; src
	ld	de, dst
	ldi
	ldi
	pop	hl
	ldi
	ldi

	di
	in	a, ($32)
	push	af
	or	%01000000
	out	($32), a
	ld	a, %10010000
	out	($35), a

	ld	hl, (dst)
	ld	de, (src)
	ld	b, 8
L21:
	push	bc
	ld	a, (de)
	ld	(hl), a
	inc	de
	inc	hl
	ld	a, (de)
	ld	(hl), a
	inc	de
	ld	bc, 79
	add	hl, bc
	pop	bc
	djnz	L21

	xor	a
	out	($35), a
	pop	af
	out	($32), a
	ei
	ret

Lend	equ	$
