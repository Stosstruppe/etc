; GAKKOU permutation for PC-8001

OUTIO	equ	$18
FOUT	equ	$2d22
MON	equ	$5c66
VALTYP	equ	$ef45
FAcc	equ	$f0a8

LEN	equ	6

	org	$d000

start proc
	ld	hl, 0
	ld	(tmp$), hl
	ld	(flag$), hl
	ld	(n$), hl
	ld	(cnt$), hl
	call	perm
	jp	MON
endp

perm proc
	ld	a, (cnt$)
	cp	100
	ret	z		; if (cnt == 100) return;

	ld	a, (n$)
	cp	LEN
	jr	nz, perm1	; if (n == LEN)

	ld	de, tmp$
	ld	hl, pick$
	ld	b, LEN
	call	memcmp
	cp	-1
	ret	nz		; if (memcmp(tmp, pick, LEN) < 0)

	ld	de, tmp$
	ld	hl, pick$
	ld	bc, LEN
	ldir			; memcpy(tmp, pick, LEN);

	ld	hl, (cnt$)
	inc	hl
	ld	(cnt$), hl
	call	print		; print(++cnt);

	ld	hl, pick$
	ld	b, LEN
	call	write		; write(pick, LEN);

	ret			; return;
perm1:
	ld	de, (n$)
	ld	hl, k$
	add	hl, de
	ld	(hl), d		; k[n] = 0;
perm_begin:
	push	hl
	ld	a, (hl)
	cp	LEN
	jr	z, perm_end	; while (k[n] < LEN)

	ld	e, a
	ld	d, 0
	ld	hl, flag$
	add	hl, de
	ld	a, (hl)
	or	a
	jr	nz, perm2	; if (flag[k[n]] == 0)

	ld	(hl), 1		; flag[k[n]] = 1;
	push	hl

	ld	hl, msg$
	add	hl, de
	ld	a, (hl)
	ld	de, (n$)
	ld	hl, pick$
	add	hl, de
	ld	(hl), a		; pick[n] = msg[k[n]];

	ld	hl, n$
	inc	(hl)		; n++;
	call	perm		; perm();
	ld	hl, n$
	dec	(hl)		; n--;

	pop	hl
	ld	(hl), 0		; flag[k[n]] = 0;
perm2:
	pop	hl
	inc	(hl)		; k[n]++;
	jp	perm_begin
perm_end:
	pop	hl
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

; print(hl)
print proc
	ld	(FAcc), hl
	ld	a, 2
	ld	(VALTYP), a
	call	FOUT
print_begin:
	ld	a, (hl)
	or	a
	jr	z, print_end
	rst	OUTIO
	inc	hl
	jp	print_begin
print_end:
	ld	a, ':'
	rst	OUTIO
	ret
endp

; write(hl, b)
write proc
	ld	a, (hl)
	rst	OUTIO
	inc	hl
	djnz	write
	ret
endp

msg$	db	'AGKKOU'
pick$	ds	LEN
tmp$	ds	LEN
flag$	ds	LEN
k$	ds	LEN
n$	dw	0
cnt$	dw	0
dmy$	db	$ff

end
