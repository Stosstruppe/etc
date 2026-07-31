; 3プレーン読み書き
; z80asm -l -b gtest2.asm

PA	equ	$fc
PB	equ	$fd
PC	equ	$fe
CW	equ	$ff

	org	$be00 - 4
	dw	start
	dw	end
start:

;------------------------------------------------
gsave:
	di
	ld	(oldsps), sp
	ld	sp, $c000
	ld	a, 4		; トラック番号
	ld	(trk), a
	ld	c, $5c
gsave1:
	out	(c), a		; gvram
	ld	hl, $c000
	ld	(addr), hl
	ld	b, 4
gsave2:
	push	bc	; [
	call	wtrk
	pop	bc	; ]
	ld	hl, trk		; trk++
	inc	(hl)
	djnz	gsave2
	inc	c		; port++
	ld	a, c
	cp	$5f
	jr	nz, gsave1
	out	($5f), a	; main ram
	ld	sp, 0
oldsps	equ	$ - 2
	ei
	rst	$38

;------------------------------------------------
wtrk:
	ld	e, $11		; 高速ライトデータ
	call	putcom
	ld	hl, param
	ld	b, 4
wtrk1:
	ld	e, (hl)
	inc	hl
	call	putdat
	djnz	wtrk1
	ld	hl, (addr)
	ld	c, 8
wtrk2:
	ld	b, 0
wtrk3:
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	call	putdat_w
	djnz	wtrk3
	dec	c
	jr	nz, wtrk2
	ld	(addr), hl
	ret

;------------------------------------------------
gload:
	di
	ld	(oldspl), sp
	ld	sp, $c000
	ld	a, 4		; トラック番号
	ld	(trk), a
	ld	c, $5c
gload1:
	out	(c), a		; gvram
	ld	hl, $c000
	ld	(addr), hl
	ld	b, 4
gload2:
	push	bc	; [
	call	rtrk
	pop	bc	; ]
	ld	hl, trk		; trk++
	inc	(hl)
	djnz	gload2
	inc	c		; port++
	ld	a, c
	cp	$5f
	jr	nz, gload1
	out	($5f), a	; main ram
	ld	sp, 0
oldspl	equ	$ - 2
	ei
	rst	$38

;------------------------------------------------
rtrk:
	ld	e, $02		; リードデータ
	call	putcom
	ld	hl, param
	ld	b, 4
rtrk1:
	ld	e, (hl)
	inc	hl
	call	putdat
	djnz	rtrk1

	ld	e, $12		; 高速センドデータ
	call	putcom
	call	getdat_w
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
	ld	hl, (addr)
	ld	c, 8
getdat_w1:
	ld	b, 0
getdat_w2:
	ld	a, %00001011	; W.RFD(5) = 1
	out	(CW), a
getdat_w3:
	in	a, (PC)
	and	$01		; R.DAV(0) == 1
	jr	z, getdat_w3
	ld	a, %00001010	; W.RFD(5) = 0
	out	(CW), a
	in	a, (PA)		; recv dat
	ld	(hl), a
	inc	hl
	ld	a, %00001101	; W.DAC(6) = 1
	out	(CW), a
getdat_w4:
	in	a, (PC)
	and	$01		; R.DAV(0) == 0
	jr	nz, getdat_w4
	in	a, (PA)		; recv dat
	ld	(hl), a
	inc	hl
	ld	a, %00001100	; W.DAC(6) = 0
	out	(CW), a
	djnz	getdat_w2
	dec	c
	jr	nz, getdat_w1
	ld	(addr), hl
	ret

;------------------------------------------------
param:
	db	16		; セクタ数
	db	0		; ドライブ番号
trk:	db	0		; トラック番号
	db	1		; セクタ番号
addr:	dw	0		; アドレス
end:
