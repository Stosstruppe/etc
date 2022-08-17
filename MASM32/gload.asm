comment *
ml /c gload.asm
link16 /t gload;
*

STDERR	equ	2

.model tiny
.code
	org	0100h
main proc
	mov	al, 00h		; 8色
	out	6ah, al
	mov	al, 4bh		; CSRFORM
	out	0a2h, al
	mov	al, 00h
	out	0a0h, al
	mov	al, 08h		; 400ライン
	out	68h, al
	mov	al, 0dh		; START
	out	0a2h, al

	; ファイルを開く
	mov	dx, offset fname
	mov	al, 00h		; read
	mov	ah, 3dh
	int	21h
	jnc	@f

	mov	dx, offset msg
	mov	cx, msglen
	mov	bx, STDERR
	mov	ah, 40h
	int	21h
	mov	ax, 4c01h
	int	21h
@@:
	mov	hfile, ax
	mov	cx, 3
@@:
	push	cx

	; ファイルを読み込む
	mov	dx, 0
	mov	cx, 32000
	mov	bx, hfile
	push	ds
	mov	ds, gseg
	mov	ah, 3fh
	int	21h
	pop	ds

	add	gseg, 800h
	pop	cx
	loop	@b

	; ファイルを閉じる
	mov	bx, hfile
	mov	ah, 3eh
	int	21h
	mov	ax, 4c00h
	int	21h
main endp

fname	db	'sample.bin', 0
hfile	dw	?
gseg	dw	0a800h
msg	db	'file open error.', 0dh, 0ah
msglen	equ	$ - msg

end main
