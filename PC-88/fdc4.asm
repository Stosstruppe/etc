; z80asm -l -b fdc4.asm
; z88dk-appmake +pc88 -b fdc4.bin --org=0xd000

PA	equ	$fc
PB	equ	$fd
PC	equ	$fe
CW	equ	$ff

	org	$d000

	ld	a, $02		; read data
	call	putcom
	ld	hl, dat1
	ld	b, 4
L1:
	ld	a, (hl)
	inc	hl
	call	putdat
	djnz	L1

	ld	a, $03		; send data
	call	putcom
	ld	hl, $cf00
	ld	b, 0
L2:
	call	getdat
	ld	(hl), a
	inc	hl
	djnz	L2
	rst	$38

dat1:	db	1, 0, 37, 1

putcom:
	ld	d, a
	ld	a, %00001111	; W.ATN(7) = 1
	out	(CW), a
putcom1:
	in	a, (PC)
	and	$02		; R.RFD(1) == 1
	jr	z, putcom1
	ld	a, %00001110	; W.ATN(7) = 0
	out	(CW), a
	ld	a, d		; send com
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

putdat:
	ld	d, a
putdat1:
	in	a, (PC)
	and	$02		; R.RFD(1) == 1
	jr	z, putdat1
	ld	a, d		; send dat
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

getdat:
	ld	a, %00001011	; W.RFD(5) = 1
	out	(CW), a
getdat1:
	in	a, (PC)
	and	$01		; R.DAV(0) == 1
	jr	z, getdat1
	ld	a, %00001010	; W.RFD(5) = 0
	out	(CW), a
	in	a, (PA)		; recv dat
	ld	d, a
	ld	a, %00001101	; W.DAC(6) = 1
	out	(CW), a
getdat2:
	in	a, (PC)
	and	$01		; R.DAV(0) == 0
	jr	nz, getdat2
	ld	a, %00001100	; W.DAC(6) = 0
	out	(CW), a
	ld	a, d
	ret
