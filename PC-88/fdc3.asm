PA	equ	$fc
PB	equ	$fd
PC	equ	$fe
CW	equ	$ff

	org	$d000

	ld	c, $02		; read data
	call	putcom
	ld	hl, param
	ld	b, 4
L1:
	ld	c, (hl)
	call	putdat
	inc	hl
	djnz	L1

	ld	c, $03		; send data
	call	putcom
	ld	hl, $d100
	ld	b, 0
L2:
	call	getdat
	ld	(hl), c
	inc	hl
	djnz	L2
	ret

; in c: command
putcom:
	ld	a, %00001111	; W.ATN(7) = 1
	out	(CW), a
putcom1:
	in	a, (PC)
	bit	1, a		; R.RFD(1) == 1
	jr	z, putcom1
	ld	a, %00001110	; W.ATN(7) = 0
	out	(CW), a
	ld	a, c
	out	(PB), a
	ld	a, %00001001	; W.DAV(4) = 1
	out	(CW), a
putcom2:
	in	a, (PC)
	bit	2, a		; R.DAC(2) == 1
	jr	z, putcom2
	ld	a, %00001000	; W.DAV(4) = 0
	out	(CW), a
	ret

; in c: data
putdat:
putdat1:
	in	a, (PC)
	bit	1, a		; R.RFD(1) == 1
	jr	z, putdat1
	ld	a, c
	out	(PB), a
	ld	a, %00001001	; W.DAV(4) = 1
	out	(CW), a
putdat2:
	in	a, (PC)
	bit	2, a		; R.DAC(2) == 1
	jr	z, putdat2
	ld	a, %00001000	; W.DAV(4) = 0
	out	(CW), a
	ret

; out c: data
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
	ld	c, a
	ld	a, %00001101	; W.DAC(6) = 1
	out	(CW), a
getdat2:
	in	a, (PC)
	bit	0, a		; R.DAV(0) == 0
	jr	nz, getdat2
	ld	a, %00001100	; W.DAC(6) = 0
	out	(CW), a
	ret

; drv 0,1
; trk 0-79
; sec 1-16
param	db	1, 0,37,1
