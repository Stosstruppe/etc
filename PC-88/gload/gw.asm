;z80asm -b -l gw.asm

PHYDIO	equ	$369a
ERRCNT	equ	$ecb4

sector	equ	$aff0
track	equ	$aff1
plane	equ	$aff2
gvram	equ	$aff3
buf	equ	$bf00

	org	$b000 - 4

	dw	Lstart		; 開始アドレス
	dw	Lend		; 終了アドレス + 1

Lstart	equ	$

	in	a, ($71)
	push	af
	ld	a, $ff
	out	($71), a	; main rom

	di
	ld	a, (plane)
	ld	c, a
	out	(c), a
	ld	hl, (gvram)
	ld	de, buf
	ld	bc, 256
	ldir
	out	($5f), a
	ei

	ld	a, 0
	ld	(ERRCNT), a
	ld	hl, buf
	ld	bc, (sector)
	scf			; write c
	call	PHYDIO

	pop	af
	out	($71), a
	ret

Lend	equ	$
