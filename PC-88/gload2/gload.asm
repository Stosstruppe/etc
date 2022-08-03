;z80asm -b -l gload.asm

port	equ	$bff0
dst	equ	$bff1
src	equ	$bff3

	org	$bf00 - 4
	dw	Lstart
	dw	Lend
Lstart	equ	$

	ld	hl, (src)
	ld	de, (dst)
	ld	a, (port)
	ld	c, a
	di
	out	(c), a
	ld	bc, 256
	ldir
	out	($5f), a
	ei
	ld	(dst), de
	ret

Lend	equ	$
