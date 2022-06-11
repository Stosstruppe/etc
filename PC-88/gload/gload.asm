;z80asm -b -l gload.asm

PHYDIO	equ	$369a
CURDRV	equ	$ec85
ERRCNT	equ	$ecb4
CURTYP	equ	$ef5d

sector	equ	$aff0
track	equ	$aff1
plane	equ	$aff2
gvram	equ	$aff3
tr	equ	$aff5
buf	equ	$bf00

	org	$b000 - 4

	dw	Lstart		; 開始アドレス
	dw	Lend		; 終了アドレス + 1

Lstart	equ	$

	ld	a, 0
	ld	(CURDRV), a
	ld	a, 3
	ld	(CURTYP), a

	ld	a, 1
	ld	(track), a
	ld	a, $5c		; for plane=$5c < $5f
Lplane:
	ld	(plane), a

	ld	hl, $c000
	ld	(gvram), hl
	ld	a, 0		; for tr=0 < 4
Ltr:
	ld	(tr), a

	ld	a, 1
Lsecotr:
	ld	(sector), a	; for sector=1 < 17

	call	readsec

	ld	hl, gvram+1
	inc	(hl)		; gvram += $100
	ld	a, (sector)
	inc	a
	cp	17
	jr	nz, Lsecotr	; next sector

	ld	hl, track
	inc	(hl)		; track++
	ld	a, (tr)
	inc	a
	cp	4
	jr	nz, Ltr		; next tr

	ld	a, (plane)
	inc	a
	cp	$5f
	jr	nz, Lplane	; next plane
L999:
	jr	L999

readsec:
	ld	a, 0
	ld	(ERRCNT), a
	ld	hl, buf
	ld	bc, (sector)
	xor	a
	inc	a		; read nc,nz
	call	PHYDIO
	di
	ld	a, (plane)
	ld	c, a
	out	(c), a
	ld	hl, buf
	ld	de, (gvram)
	ld	bc, 256
	ldir
	out	($5f), a
	ei
	ret

Lend	equ	$
