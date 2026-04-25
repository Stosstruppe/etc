; ml /c /Fl banner.asm
; link16 /t banner;

	.model	tiny
	.code
	org	100h
start:
	mov	si, 0080h
	cld
	lodsb
	cmp	al, 0
	jne	@f		; if (len == 0) return
	ret
@@:
	dec	al
	cmp	al, 9
	jbe	@f		; if (len > 9) len = 9
	mov	al, 9
@@:
	mov	len, al
	mov	col, al
	lodsb
	mov	ah, 14h
	mov	bx, ds
	mov	cx, offset buf	; p = buf
	mov	dh, 0
L1:				; for (col = len; col; col--)
	lodsb
	mov	dl, al
	int	18h
	add	cx, 10		; p += 10
	dec	col
	jnz	L1

	mov	row, 0		; for (row = 0; row < 8; row++)
Lrow:
	mov	si, offset buf + 2
	add	si, row
	mov	al, len
	mov	col, al		; for (col = len; col; col--)
Lcol:
	mov	dh, [si]
	mov	cx, 8		; for (dot = 8; dot; dot--)
Ldot:
	mov	dl, ' '
	shl	dh, 1
	jnc	@f
	mov	dl, '#'
@@:
	mov	ah, 02h
	int	21h
	loop	Ldot

	add	si, 10
	dec	col
	jnz	Lcol

	mov	ah, 02h
	mov	dl, 0dh		; cr
	int	21h
	mov	dl, 0ah		; lf
	int	21h
	inc	row
	cmp	row, 8
	jne	Lrow
	ret

len	db	?
col	db	?
row	dw	?
buf	db	10*9 dup (?)

	end	start
