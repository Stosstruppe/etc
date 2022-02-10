comment *
ml /c /AT /Fl perm.asm
link16 /t perm;
*
.186
.model tiny

LEN	equ	6

.code
	org	0100h
;
main proc
	mov	p$, offset rec
	push	0
	call	perm
	add	sp, 2
	call	sort
	call	disp
	ret
main endp

; void perm(int n)
; bp-2 i
; bp+0 save bp
; bp+2 ret addr
; bp+4 n
perm proc
	push	bp
	mov	bp, sp
	sub	sp, 2
	push	si
	push	di

	cmp	word ptr [bp+4], LEN
	jnz	@f				; if (n == LEN)
	mov	si, offset pick
	mov	di, p$
	mov	cx, LEN
	cld
	rep movsb				; memcpy(p, pick);
	add	p$, LEN				; p += LEN;
	inc	cnt
	jmp	perm_exit			; return;
@@:
	mov	word ptr [bp-2], 0		; int i = 0;
perm1:
	cmp	word ptr [bp-2], LEN
	jz	perm_exit			; i < LEN;
	mov	si, [bp-2]
	cmp	byte ptr [si+offset flag], 0
	jnz	@f				; if (flag[i] == 0)
	mov	byte ptr [si+offset flag], 1	; flag[i] = 1;
	mov	al, byte ptr [si+offset msg]
	mov	di, [bp+4]
	mov	byte ptr [di+offset pick], al	; pick[n] = msg[i];
	inc	di
	push	di
	call	perm				; perm(n + 1);
	add	sp, 2
	mov	byte ptr [si+offset flag], 0	; flag[i] = 0;
@@:
	inc	word ptr [bp-2]			; i++;
	jmp	perm1
perm_exit:
	pop	di
	pop	si
	leave					; mov sp,bp; pop bp
	ret
perm endp

;
sort proc
	mov	ax, cnt
	dec	ax
	mov	iend, ax	; iend = cnt - 1
	mov	i$, 0		; i = 0
OutBegin:
	mov	ax, i$
	cmp	ax, iend
	jae	OutEnd		; i < iend

	mov	p$, offset rec
	mov	p1$, offset rec + LEN
	mov	ax, iend
	sub	ax, i$
	mov	jend, ax	; jend = iend - i
	mov	j$, 0		; j = 0
InBegin:
	mov	ax, j$
	cmp	ax, jend
	jae	InEnd		; j < jend

	mov	di, p$
	mov	si, p1$
	mov	cx, LEN
	call	memcmp
	cmp	al, -1
	jne	@f

	mov	di, p$
	mov	si, p1$
	mov	cx, LEN
	call	swap
@@:
	add	p$, LEN
	add	p1$, LEN
	inc	j$		; j++
	jmp	InBegin
InEnd:
	inc	i$		; i++
	jmp	OutBegin
OutEnd:
	ret
sort endp

; al = memcmp(di, si, cx)
memcmp proc
@@:
	mov	al, [si]
	cmp	al, [di]
	jne	@f
	inc	si
	inc	di
	loop	@b
	mov	al, 0
	jmp	memcmp_exit
@@:
	mov	al, 1
	ja	memcmp_exit
	mov	al, -1
memcmp_exit:
	ret
memcmp endp

; swap(di, si, cx)
swap proc
@@:
	mov	al, [di]
	mov	ah, [si]
	mov	[di], ah
	mov	[si], al
	inc	di
	inc	si
	loop	@b
	ret
swap endp

;
disp proc
	; for (i = 0; i < cnt; i++)
	; write(p, LEN);
	; p += LEN;
	mov	j$, 0
	mov	p$, offset rec
	mov	i$, 0
disp_begin:
	mov	ax, i$
	cmp	ax, cnt
	je	disp_end

	mov	di, offset tmp
	mov	si, p$
	mov	cx, LEN
	call	memcmp
	cmp	al, 0
	je	@f

	mov	di, offset tmp
	mov	si, p$
	mov	cx, LEN
	cld
	rep movsb
	inc	j$
	mov	ax, j$
	call	print
	mov	si, p$
	mov	cx, LEN
	call	write
	cmp	j$, 100
	je	disp_end
@@:
	add	p$, LEN
	inc	i$
	jmp	disp_begin
disp_end:
	ret
disp endp

; write(si, cx)
write proc
	mov	ah, 02h
@@:
	mov	dl, [si]
	int	21h
	inc	si
	loop	@b
	mov	dl, ' '
	int	21h
	ret
write endp

; print(ax)
print proc
	mov	di, offset buf + 5
	mov	bx, 10
@@:
	mov	dx, 0
	div	bx
	or	dl, '0'
	dec	di
	mov	[di], dl
	cmp	ax, 0
	jne	@b
	mov	dx, di
	mov	ah, 09h
	int	21h
	ret
print endp

msg	db	'GAKKOU'
buf	db	'xxxxx:$'
pick	db	LEN dup (?)
tmp	db	LEN dup (?)
flag	db	LEN dup (?)
rec	db	LEN * 720 dup (?)
cnt	dw	?
p$	dw	?
p1$	dw	?
i$	dw	?
j$	dw	?
iend	dw	?
jend	dw	?

end main
