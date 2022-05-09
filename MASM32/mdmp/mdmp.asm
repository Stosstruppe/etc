comment *
ml /c /AT /Fl mdmp.asm
link16 /t mdmp;
*
.186
.model tiny
.code
	org	0100h
start:
	mov	ax, ds
	mov	es, ax
	mov	si, 0000h
	call	mdmp
	ret

; memory dump
; in:	si: 読込アドレス
mdmp:
	mov	cx, 16
mdmp1:
	push	cx
	mov	adrs, si
	call	ldmp
	mov	si, adrs
	add	si, 16
	pop	cx
	loop	mdmp1
	ret

; line dump
; in:	si: 読込アドレス
ldmp:
	cld
	mov	di, offset line
	mov	ax, si
	xchg	ah, al
	call	bdmp
	mov	ax, si
	call	bdmp

	mov	di, offset line + 5
	mov	cx, 16
ldmp1:
	lodsb
	call	bdmp
	inc	di		; skip
	loop	ldmp1

	mov	si, adrs
	mov	di, offset line + 5+3*16
	mov	cx, 16
ldmp2:
	lodsb
	call	admp
	loop	ldmp2

	mov	dx, offset line
	mov	ah, 09h
	int	21h
	ret

; binary dump
; in:	al: 値
; 	di: 書込アドレス
bdmp:
	mov	bx, offset hdigit
	mov	ah, al
	and	al, 0fh
	xlat			; al<-[bx+al]
	xchg	ah, al
	shr	al, 4
	xlat
	stosw
	ret

; ascii dump
; in:	al: 値
; 	di: 書込アドレス
admp:
	cmp	al, 20h
	jb	admp1		; al < 20h
	cmp	al, 7fh
	jae	admp1		; al >= 7fh
	cmp	al, '$'
	jne	admp2		; al != '$'
admp1:
	mov	al, '.'
admp2:
	stosb
	ret

hdigit	db	'0123456789ABCDEF'
line	db	'xxxx:xx xx xx xx-xx xx xx xx-xx xx xx xx-xx xx xx xx:'
	db	'0123456789abcdef',0dh,0ah,'$'
adrs	dw	0

end start
