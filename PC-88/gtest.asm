; gプレーン読み書き
; z80asm -l -b gtest.asm
; z88dk-appmake +pc88 -b gtest.bin --org=0xbe00

PA	equ	$fc
PB	equ	$fd
PC	equ	$fe
CW	equ	$ff

	org	$be00

;------------------------------------------------
gsave:
	di
	ld	(oldsps), sp
	ld	sp, $c000
	out	($5e), a	; vram G
	ld	hl, $c000
	ld	c, 4		; トラック番号
	ld	b, 4
gsave1:
	push	bc
	call	wtrk
	pop	bc
	inc	c
	djnz	gsave1
	out	($5f), a	; main ram
	ld	sp, 0
oldsps	equ	$ - 2
	ei
	rst	$38

;------------------------------------------------
wtrk:
	ld	e, $11		; 高速ライトデータ
	call	putcom
	ld	e, 16		; セクタ数
	call	putdat
	ld	e, 0		; ドライブ番号
	call	putdat
	ld	e, c		; トラック番号
	call	putdat
	ld	e, 1		; セクタ番号
	call	putdat
	ld	c, 8
wtrk1:
	ld	b, 0
wtrk2:
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	call	putdat_w
	djnz	wtrk2
	dec	c
	jr	nz, wtrk1
	ret

;------------------------------------------------
gload:
	di
	ld	(oldspl), sp
	ld	sp, $c000
	out	($5e), a	; vram G
	ld	hl, $c000
	ld	c, 4		; トラック番号
	ld	b, 4
gload1:
	push	bc
	call	rtrk
	pop	bc
	inc	c
	djnz	gload1
	out	($5f), a	; main ram
	ld	sp, 0
oldspl	equ	$ - 2
	ei
	rst	$38

;------------------------------------------------
rtrk:
	ld	e, $02		; リードデータ
	call	putcom
	ld	e, 16		; セクタ数
	call	putdat
	ld	e, 0		; ドライブ番号
	call	putdat
	ld	e, c		; トラック番号
	call	putdat
	ld	e, 1		; セクタ番号
	call	putdat

	ld	e, $12		; 高速センドデータ
	call	putcom
	ld	c, 8
rtrk1:
	ld	b, 0
rtrk2:
	call	getdat_w
	ld	(hl), e
	inc	hl
	ld	(hl), d
	inc	hl
	djnz	rtrk2
	dec	c
	jr	nz, rtrk1
	ret

;------------------------------------------------
putcom:
	ld	a, %00001111	; W.ATN(7) = 1
	out	(CW), a
putcom1:
	in	a, (PC)
	and	$02		; R.RFD(1) == 1
	jr	z, putcom1
	ld	a, %00001110	; W.ATN(7) = 0
	out	(CW), a
	ld	a, e		; send com
	out	(PB), a
	ld	a, %00001001	; W.DAV(4) = 1
	out	(CW), a
putcom2:
	in	a, (PC)
	and	$04		; R.DAC(2) == 1
	jr	z, putcom2
	ld	a, %00001000	; W.DAV(4) = 0
	out	(CW), a
	ret

;------------------------------------------------
putdat:
putdat1:
	in	a, (PC)
	and	$02		; R.RFD(1) == 1
	jr	z, putdat1
	ld	a, e		; send dat
	out	(PB), a
	ld	a, %00001001	; W.DAV(4) = 1
	out	(CW), a
putdat2:
	in	a, (PC)
	and	$04		; R.DAC(2) == 1
	jr	z, putdat2
	ld	a, %00001000	; W.DAV(4) = 0
	out	(CW), a
	ret

;------------------------------------------------
putdat_w:
putdat_w2:
	in	a, (PC)
	and	$02		; R.RFD(1) == 1
	jr	z, putdat_w2
	ld	a, e		; send dat
	out	(PB), a
	ld	a, %00001001	; W.DAV(4) = 1
	out	(CW), a
putdat_w3:
	in	a, (PC)
	and	$04		; R.DAC(2) == 1
	jr	z, putdat_w3
	ld	a, d		; send dat
	out	(PB), a
	ld	a, %00001000	; W.DAV(4) = 0
	out	(CW), a
	ret

;------------------------------------------------
getdat_w:
	ld	a, %00001011	; W.RFD(5) = 1
	out	(CW), a
getdat_w1:
	in	a, (PC)
	and	$01		; R.DAV(0) == 1
	jr	z, getdat_w1
	ld	a, %00001010	; W.RFD(5) = 0
	out	(CW), a
	in	a, (PA)		; recv dat
	ld	e, a
	ld	a, %00001101	; W.DAC(6) = 1
	out	(CW), a
getdat_w2:
	in	a, (PC)
	and	$01		; R.DAV(0) == 0
	jr	nz, getdat_w2
	in	a, (PA)		; recv dat
	ld	d, a
	ld	a, %00001100	; W.DAC(6) = 0
	out	(CW), a
	ret
