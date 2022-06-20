;z80asm -b -l spr.asm

pdst	equ	$bf00
psrc	equ	$bf02

org	$bb00 - 4
	dw	Lstart
	dw	Lend
Lstart	equ	$
				; パラメタ
	push	hl
	pop	ix
	ld	a, (ix+0)
	ld	(pdst+0), a
	ld	a, (ix+1)
	ld	(pdst+1), a
	push	de
	pop	ix
	ld	a, (ix+0)
	ld	(psrc+0), a
	ld	a, (ix+1)
	ld	(psrc+1), a

	ld	hl, (psrc)
	di
	out	($5d), a	; Rプレーン
	ld	de, (pdst)
	ld	b, 16
L1:
	push	bc
	ld	bc, 4
	ldir
	ex	de, hl
	ld	bc, 76
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	L1

	out	($5e), a	; Gプレーン
	ld	de, (pdst)
	ld	b, 16
L2:
	push	bc
	ld	bc, 4
	ldir
	ex	de, hl
	ld	bc, 76
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	L2

	out	($5f), a	; メインRAM
	ei
	ret

Lend	equ	$
