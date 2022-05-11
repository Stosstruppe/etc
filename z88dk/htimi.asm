;z80asm -b -ohtimi.com htimi.asm

C_WRITE	equ	$02	; Console output
C_STAT	equ	$0b	; Console status

PSLTRG	equ	$a8	; primary slot register
EXPTBL	equ	$fcc1
H_TIMI	equ	$fd9f

	org	$0100

	di
	ld	hl, H_TIMI
	ld	de, htimi
	ld	bc, 5
	ldir

	in	a, (PSLTRG)
	rrca
	rrca
	and	$03
	ld	c, a
	ld	b, 0
	ld	hl, EXPTBL
	add	hl, bc
	or	(hl)
	ld	c, a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a, (hl)
	and	$0c
	or	c

	ld	ix, H_TIMI
	ld	hl, hook
	ld	(ix+0), $f7	; rst $30
	ld	(ix+1), a
	ld	(ix+2), l
	ld	(ix+3), h
	ld	(ix+4), $c9	; ret
	ei
main1:
	ld	a, (cnt)
	and	$0f
	or	$40
	ld	e, a
	ld	c, C_WRITE
	call	5
	ld	c, C_STAT
	call	5
	or	a
	jr	z, main1

	di
	ld	hl, htimi
	ld	de, H_TIMI
	ld	bc, 5
	ldir
	ei
	ret

hook:
	ld	hl, cnt
	inc	(hl)
htimi:	ds	5

cnt:	db	0
