;z80asm -b -l ipl.asm

PHYDIO	equ	$369a
CURDRV	equ	$ec85
ERRCNT	equ	$ecb4
CURTYP	equ	$ef5d

	org	$c000 - 4

	dw	Lstart		; 開始アドレス
	dw	Lend		; 終了アドレス + 1

Lstart	equ	$

	ld	a, 0		; 0/1
	ld	(CURDRV), a
	ld	a, 3		; 5inch 2D
	ld	(CURTYP), a
	ld	a, 0
	ld	(ERRCNT), a
	ld	hl, $b000	; dst
	ld	b, 0		; track
	ld	c, 2		; sector
	xor	a
	inc	a		; read nc,nz
	call	PHYDIO
	jp	$b000

Lend	equ	$
