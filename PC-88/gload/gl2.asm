;z80asm -b -l gl2.asm

PA	equ	$fc
PB	equ	$fd
PC	equ	$fe
CW	equ	$ff

sector	equ	$aff0
track	equ	$aff1
plane	equ	$aff2
gvram	equ	$aff3
tr	equ	$aff5
drive	equ	$aff6

	org	$b000 - 4
	dw	Lstart
	dw	Lend
Lstart	equ	$

	ld	a, 1
	ld	(drive), a
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

	ld	hl, (gvram)
	ld	bc, (sector)
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
	ret

; in	hl	読込アドレス
;	b	トラック (0-79)
;	c	セクタ (1-16)
;	drive	ドライブ (0-1)
;	plane	プレーン ($5c-$5e)
readsec:
	ld	a, $02		; read data
	call	putcom
	ld	a, 1		; セクタ数
	call	putdat
	ld	a, (drive)	; ドライブ番号
	call	putdat
	ld	a, b		; トラック番号
	call	putdat
	ld	a, c		; セクタ番号
	call	putdat

	ld	a, $03		; send data
	call	putcom
	di
	ld	a, (plane)
	ld	c, a
	out	(c), a
	ld	b, 0
phydio1:
	call	getdat
	ld	(hl), a
	inc	hl
	djnz	phydio1
	out	($5f), a
	ei
	ret

; in	a	command
putcom:
	push	af
	ld	a, %00001111	; W.ATN(7) = 1
	out	(CW), a
	pop	af

; in	a	data
putdat:
	push	af
putdat1:
	in	a, (PC)
	bit	1, a		; R.RFD(1) == 1
	jr	z, putdat1

	ld	a, %00001110	; W.ATN(7) = 0
	out	(CW), a
	pop	af
	out	(PB), a
	ld	a, %00001001	; W.DAV(4) = 1
	out	(CW), a
putdat2:
	in	a, (PC)
	bit	2, a		; R.DAC(2) == 1
	jr	z, putdat2
putdat3:
	ld	a, %00001000	; W.DAV(4) = 0
	out	(CW), a
	ret

; out	a	data
getdat:
	ld	a, %00001011	; W.RFD(5) = 1
	out	(CW), a
getdat1:
	in	a, (PC)
	bit	0, a		; R.DAV(0) == 1
	jr	z, getdat1

	ld	a, %00001010	; W.RFD(5) = 0
	out	(CW), a
	in	a, (PA)
	push	af
	ld	a, %00001101	; W.DAC(6) = 1
	out	(CW), a
getdat2:
	in	a, (PC)
	bit	0, a		; R.DAV(0) == 0
	jr	nz, getdat2
getdat3:
	ld	a, %00001100	; W.DAC(6) = 0
	out	(CW), a
	pop	af
	ret

Lend	equ	$
