comment *
ml /c /AT /Fl vga13h.asm
link16 /t vga13h;
*

.model tiny
.8086
.code
	org	0100h
start:
	mov	al, 13h
	int	10h
	les	ax, [bx]
L1:
	mov	ax, di
	xor	dx, dx
	mov	cx, 320
	div	cx
	mov	al, dl
	stosb
	jmp	L1

end	start
