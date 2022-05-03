;z80asm -b -l -odmp.com dmp.asm

	org	$0100

	ld	hl, _buf
	ld	b, 8
L1:
	push	bc
	ld	(_addr), hl
	ld	a, (hl)
	rrca
	rrca
	rrca
	rrca
	call	L2
	ld	hl, (_addr)
	ld	a, (hl)
	call	L2
	ld	e, ' '
	ld	c, $02
	call	5
	ld	hl, (_addr)
	inc	hl
	pop	bc
	djnz	L1
	ret
L2:
	and	$0f
	or	$30
	cp	$3a
	jr	c, L3
	add	a, 7
L3:
	ld	e, a
	ld	c, $02
	call	5
	ret

_buf:	db	$01,$23,$45,$67, $89,$ab,$cd,$ef
_addr:	dw	0
