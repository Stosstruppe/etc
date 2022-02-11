;10 screen 0:width 80
;20 bload "program.bin",r

CHPUT	equ	$00a2
FOUT	equ	$3425
VALTYP	equ	$f663
DAC	equ	$f7f6

LEN	equ	6

	org	$9000
;
main proc
	ld	hl, rec
	ld	(p$), hl	; p = rec;
	ld	hl, 0
	ld	(cnt), hl	; cnt = 0;
	push	hl
	call	perm		; perm(0);
	pop	de
	call	sort
	call	disp
	ret
endp

; void perm(int n)
; ix-2 i
; ix+0 save ix
; ix+2 ret addr
; ix+4 n
perm proc
	push	ix
	ld	ix, 0
	add	ix, sp

	ld	a, (ix+4)
	cp	LEN
	jp	nz, L1		; if (n == LEN)

	ld	de, (p$)
	ld	hl, pick
	ld	bc, LEN
	ldir			; memcpy(p, pick, LEN);
	ld	(p$), de	; p += LEN;
	ld	hl, (cnt)
	inc	hl
	ld	(cnt), hl	; cnt++;
	jp	L99		; return;
L1:
	ld	hl, 0
	push	hl		; int i = 0;
L2:
	ld	a, (ix-2)
	cp	LEN
	jr	z, L99		; i < LEN;

	ld	hl, flag
	ld	e, a
	ld	d, 0
	add	hl, de
	ld	a, (hl)
	or	a
	jp	nz, L3		; if (flag[i] == 0)

	ld	(hl), 1		; flag[i] = 1;
	ld	hl, msg
	ld	e, (ix-2)
	add	hl, de
	ld	a, (hl)
	ld	hl, pick
	ld	e, (ix+4)
	add	hl, de
	ld	(hl), a		; pick[n] = msg[i];

	inc	e
	push	de
	call	perm		; perm(n + 1);
	pop	de

	ld	hl, flag
	ld	e, (ix-2)
	ld	d, 0
	add	hl, de
	ld	(hl), 0		; flag[i] = 0;
L3:
	inc	(ix-2)		; i++;
	jp	L2
L99:
	ld	sp, ix
	pop	ix
	ret
endp

;
sort proc
	ld	hl, (cnt)
	dec	hl
	ld	(iend), hl	; iend = cnt - 1;
	ld	hl, 0
	ld	(i$), hl	; i = 0;
out_begin:
	ld	hl, (iend)
	ld	de, (i$)
	or	a
	sbc	hl, de
	jr	z, out_end	; i < iend;

	ld	(jend), hl	; jend = iend - i;
	ld	hl, 0
	ld	(j$), hl	; j = 0;
	ld	hl, rec
	ld	(p$), hl	; p = rec;
	ld	hl, rec + LEN
	ld	(q$), hl	; q = rec + LEN;
in_begin:
	ld	hl, (jend)
	ld	de, (j$)
	or	a
	sbc	hl, de
	jr	z, in_end	; j < jend;

	ld	de, (p$)
	ld	hl, (q$)
	ld	b, LEN
	call	memcmp		; memcmp(p, q, LEN);
	cp	1
	jr	nz, sort1

	ld	de, (p$)
	ld	hl, (q$)
	ld	b, LEN
	call	swap
sort1:
	ld	hl, (q$)
	ld	(p$), hl	; p = q;
	ld	de, LEN
	add	hl, de
	ld	(q$), hl	; q += LEN;
	ld	hl, (j$)
	inc	hl
	ld	(j$), hl	; j++;
	jp	in_begin
in_end:
	ld	a, '.'
	call	CHPUT
	ld	hl, (i$)
	inc	hl
	ld	(i$), hl	; i++;
	jp	out_begin
out_end:
	ret
endp

; a = memcmp(de, hl, b)
memcmp proc
	ld	a, (de)
	cp	(hl)
	jr	nz, memcmp_end
	inc	de
	inc	hl
	djnz	memcmp
	xor	a
	ret
memcmp_end:
	ld	a, 1
	ret	nc
	ld	a, -1
	ret
endp

; swap(de, hl, b)
swap proc
	ld	c, (hl)
	ld	a, (de)
	ld	(hl), a
	ld	a, c
	ld	(de), a
	inc	de
	inc	hl
	djnz	swap
	ret
endp

;
disp proc
	ld	hl, rec
	ld	(p$), hl	; p = rec;
	ld	hl, 0
	ld	(i$), hl	; i = 0;
	ld	(j$), hl	; j = 0;
disp_begin:
	ld	hl, (i$)
	ld	de, (cnt)
	or	a
	sbc	hl, de
	jr	z, disp_end	; i < cnt;

	ld	de, tmp
	ld	hl, (p$)
	ld	b, LEN
	call	memcmp
	jr	z, disp_skip

	ld	de, tmp
	ld	hl, (p$)
	ld	bc, LEN
	ldir			; memcpy(tmp, p, LEN);
	ld	hl, (j$)
	inc	hl
	ld	(j$), hl
	call	print		; printf(" %d:", ++j);
	ld	hl, (p$)
	ld	b, LEN
	call	write		; write(p, LEN);

	ld	hl, (j$)
	ld	de, 100
	or	a
	sbc	hl, de
	jr	z, disp_end	; if (j >= 100) return;
disp_skip:
	ld	hl, (p$)
	ld	de, LEN
	add	hl, de
	ld	(p$), hl	; p += LEN;
	ld	hl, (i$)
	inc	hl
	ld	(i$), hl	; i++;
	jp	disp_begin
disp_end:
	ret
endp

; print(hl)
print proc
	ld	(DAC+2), hl
	ld	a, 2
	ld	(VALTYP), a
	call	FOUT
print_begin:
	ld	a, (hl)
	or	a
	jr	z, print_end
	call	CHPUT
	inc	hl
	jp	print_begin
print_end:
	ld	a, ':'
	call	CHPUT
	ret
endp

; write(hl, b)
write proc
	ld	a, (hl)
	call	CHPUT
	inc	hl
	djnz	write
	ret
endp

msg	db	'GAKKOU'
flag	ds	LEN
pick	ds	LEN
tmp	ds	LEN
rec	ds	LEN * 720
cnt	ds	2
p$	ds	2
q$	ds	2
i$	ds	2
j$	ds	2
iend	ds	2
jend	ds	2

end main
