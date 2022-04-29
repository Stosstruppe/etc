.186

CGROUP	group	TEXT
DGROUP	group	DATA

DATA	dseg

; Unit Control Work
ucw:
gbon_ptn:	db	0	; color
gbbcc:		db	0
gbdotu:		db	3	; pset
gbdsp:		db	0
gbcpc:		db	0,0,0,0
gbsx1:		dw	0
gbsy1:		dw	0
gblng1:		dw	0
gbwdpa:		dw	0
gbrbuf:		dw	0,0,0
gbsx2:		dw	0
gbsy2:		dw	0
gbmdot:		dw	0
gbcir:		dw	0
gblng2:		dw	0
gblptn:		dw	0ffffh
gbdoti:		dw	0,0,0
gbdtyp:		db	1

TEXT	cseg

ginit_::
	push	cx

	mov	ah, 40h
	int	18h
	mov	ah, 42h
	mov	ch, 0c0h
	int	18h

	pop	cx
	ret

line_::
	push	bp
	mov	bp, sp
	push	cx

	mov	[gbsx1], ax
	mov	[gbsy1], bx
	mov	[gbsx2], cx
	mov	[gbsy2], dx
	mov	ax, [bp+4]
	mov	[gbon_ptn], al

	mov	ah, 47h
	mov	ch, 0b0h
	mov	bx, ucw
	int	18h

	pop	cx
	pop	bp
	ret

	end
