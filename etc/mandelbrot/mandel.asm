comment *
ml /c /AT /Fl mandel.asm
link16 /t mandel;
*

.model tiny
.386
.code
	org	0100h
start:
	mov	al, 13h
	int	10h
	les	ax, [bx]
L0106:
	cwd
	mov	ax, di
	mov	cx, 0140h
	div	cx
	sub	ax, 64h
	dec	dh
	xor	bx, bx
	xor	si, si
L0117:
	mov	bp, si
	imul	si, bx
	add	si, si
	imul	bx, bx
	jo	L013C
	imul	bp, bp
	jo	L013C
	add	bx, bp
	jo	L013C
	sub	bx, bp
	sub	bx, bp
	sar	bx, 06h
	add	bx, dx
	sar	si, 06h
	add	si, ax
	loop	L0117
L013C:
	xchg	ax, cx
	stosb
	jmp	L0106

end	start
