;z80asm -b -odmp.com dmp.asm

	org	$0100

	ld	hl, $0000
	ld	b, 16
main1:
	push	bc
	push	hl
	call	ldmp
	pop	hl
	ld	de, 8
	add	hl, de
	pop	bc
	djnz	main1
	ret

; in:	hl: 読込アドレス
ldmp:
	ld	de, line + 5
	ld	b, 8
ldmp1:
	ld	c, (hl)
	call	bdmp
	inc	de
	inc	hl
	djnz	ldmp1
	ld	de, line
	ld	c, $09
	call	5
	ret

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

line:	db	"xxxx:xx xx xx xx-xx xx xx xx",$0d,$0a,"$"
