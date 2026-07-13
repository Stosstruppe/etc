comment *
MASM32
ml /c /Fl groll.asm
link16 /t groll;
*
	.186
	.model	tiny
	.code
	org	100h
start:
	jmp	main
old0A	label	dword
o0Aoff	dw	?
o0Aseg	dw	?
sad1	dw	?
sl1	dw	?
sad2	dw	0
sl2	dw	?
y	dw	0

new0A:
	pusha
	push	ds
	mov	ax, cs
	mov	ds, ax

	mov	ax, y
	inc	ax
	cmp	ax, 400
	jb	@f
	mov	ax, 0
@@:
	mov	y, ax
	mov	sl2, ax
	mov	dx, 400
	sub	dx, ax
	mov	sl1, dx
	mov	dx, 40
	mul	dx
	mov	sad1, ax
@@:
	in	al, 0a0h
	and	al, 20h
	jnz	@b
@@:
	in	al, 0a0h
	and	al, 20h
	jz	@b

	mov	al, 70h		; gdc scroll
	out	0a2h, al

	mov	ax, sad1
	out	0a0h, al
	mov	al, ah
	out	0a0h, al
	mov	ax, sl1
	shl	ax, 4
	out	0a0h, al
	mov	al, ah
	out	0a0h, al

	mov	ax, sad2
	out	0a0h, al
	mov	al, ah
	out	0a0h, al
	mov	ax, sl2
	shl	ax, 4
	out	0a0h, al
	mov	al, ah
	out	0a0h, al

	pop	ds
	popa
	out	64h, al		; vsyncリセット
	jmp	cs:[old0A]

TSRBYTE	equ	$ - start + 100h
TSRPARA	equ	(TSRBYTE+15)/16

main:
	mov	ax, 350ah	; 割り込みベクタ取得
	int	21h		; es:bx
	mov	o0Aoff, bx
	mov	o0Aseg, es

	mov	dx, new0A
	mov	ax, 250ah	; 割り込みベクタ設定
	int	21h		; ds:dx

	in	al, 02h
	and	al, 0fbh	; vsync割り込みマスク
	out	02h, al
	sti
	out	64h, al		; vsyncリセット

	mov	dx, TSRPARA
	mov	ax, 3100h	; 常駐開始
	int	21h

	end	start
