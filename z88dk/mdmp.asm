;z80asm -b -omdmp.com mdmp.asm

	org	$0100

	ld	hl, $0000
	call	mdmp
	ret

; memory dump
; in:	hl: 読込アドレス
mdmp:
	ld	b, 16
mdmp1:
	push	bc
	ld	(addr), hl
	call	ldmp
	ld	hl, (addr)
	ld	de, 16
	add	hl, de
	pop	bc
	djnz	mdmp1
	ret

; line dump
; in:	hl: 読込アドレス
ldmp:
	ld	de, line
	ld	c, h
	call	bdmp
	ld	c, l
	call	bdmp

	ld	de, line+5
	ld	b, 16
ldmp1:
	ld	c, (hl)
	call	bdmp
	inc	de		; skip
	inc	hl
	djnz	ldmp1

	ld	hl, (addr)
	ld	de, line+5+3*16
	ld	b, 16
ldmp2:
	ld	a, (hl)
	call	admp
	inc	hl
	djnz	ldmp2

	ld	de, line
	ld	c, $09
	call	5
	ret

; binary dump
; in:	c : 値
; 	de: 書込アドレス
bdmp:
	ld	a, c
	rrca
	rrca
	rrca
	rrca
	call	bdmp1
	ld	a, c
bdmp1:
	and	$0f
	or	$30
	cp	$3a
	jr	c, bdmp2
	add	a, 7
bdmp2:
	ld	(de), a
	inc	de
	ret

; ascii dump
; in:	a : 値
; 	de: 書込アドレス
admp:
	cp	$20
	jr	c, admp1	; a < $20
	cp	$7f
	jr	nc, admp1	; a >= $7f
	cp	'$'
	jr	nz, admp2	; a != '$'
admp1:
	ld	a, '.'
admp2:
	ld	(de), a
	inc	de
	ret

line:	db	"xxxx:xx xx xx xx-xx xx xx xx-xx xx xx xx-xx xx xx xx:"
	db	"0123456789abcdef",$0d,$0a,"$"
addr:	dw	0
