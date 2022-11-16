;z80asm -b -l asciiart
;z88dk-appmake +pc88 -b asciiart.bin --org=0xd000

BASE	equ	2048
DX	equ	94	; 0.0458 * BASE
DY	equ	171	; 0.08333 * BASE

	org	$d000

	xor	a
	ld	($ea60), a	; function
	ld	($ea59), a	; cursor
	ld	b, 80
	ld	c, 25
	call	$093a		; width

	ld	hl, -12 * DY	; cb = -12 * DY;
	ld	(_cb), hl
	ld	b, 25
y_begin:
	push	bc
	ld	hl, -39 * DX	; ca = -39 * DX;
	ld	(_ca), hl
				; putchar('\n');
	ld	a, $0d
	rst	18h
	ld	a, $0a
	rst	18h
	ld	b, 79
x_begin:
	push	bc
	ld	hl, (_ca)	; a = ca;
	ld	(_a), hl
	ld	hl, (_cb)	; b = cb;
	ld	(_b), hl
				; aa = a * a;
	ld	hl, (_a)
	ld	b, h
	ld	c, l
	call	mul
	ld	(_aa), hl
				; bb = b * b;
	ld	hl, (_b)
	ld	b, h
	ld	c, l
	call	mul
	ld	(_bb), hl

	ld	hl, 0		; i = 0;
	ld	(_i), hl
i_begin:
				; b = 2 * a * b + cb;
	ld	hl, (_a)
	ld	bc, (_b)
	call	mul
	add	hl, hl
	ld	de, (_cb)
	add	hl, de
	ld	(_b), hl
				; a = aa - bb + ca;
	ld	hl, (_aa)
	ld	de, (_bb)
	or	a
	sbc	hl, de
	ld	de, (_ca)
	add	hl, de
	ld	(_a), hl
				; aa = a * a;
	ld	hl, (_a)
	ld	b, h
	ld	c, l
	call	mul
	ld	(_aa), hl
				; bb = b * b;
	ld	hl, (_b)
	ld	b, h
	ld	c, l
	call	mul
	ld	(_bb), hl
				; if ((aa + bb) > (4 * BASE)) break;
	ld	hl, (_aa)
	ld	de, (_bb)
	add	hl, de
	ld	de, 4 * BASE + 1
	or	a
	sbc	hl, de
	jr	nc, i_end
				; i++;
	ld	a, (_i)
	inc	a
	ld	(_i), a
	cp	16
	jp	nz, i_begin
i_end:
				; putchar(hex[i]);
	ld	de, hex
	ld	hl, (_i)
	add	hl, de
	ld	a, (hl)
	rst	18h
				; ca += DX;
	ld	hl, (_ca)
	ld	de, DX
	add	hl, de
	ld	(_ca), hl

	pop	bc
	dec	b
	jp	nz, x_begin
				; cb += DY;
	ld	hl, (_cb)
	ld	de, DY
	add	hl, de
	ld	(_cb), hl

	pop	bc
	dec	b
	jp	nz, y_begin

	jr	$

; hl <- hl * bc / BASE
mul:
	push	hl		; <-- hl
	push	bc		; <-- bc
	ex	de, hl

	ld	hl, 0
	sla	e
	rl	d
	jr	nc, $+4
	ld	h, b
	ld	l, c

	ld	a, 15
mul_loop:
	add	hl, hl
	rl	e
	rl	d
	jr	nc, $+6
	add	hl, bc
	jr	nc, $+3
	inc	de

	dec	a
	jr	nz, mul_loop
				; 符号補正
	pop	bc		; --> bc
	ex	(sp), hl
	ex	de, hl
	bit	7, d
	jr	z, $+5
	or	a
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	or	a
	sbc	hl, de
	ex	de, hl
	pop	hl		; --> hl
				; de:hl /= BASE;
	ld	a, d
	ld	h, e
	ld	l, h
	rra
	rr	h
	rr	l
	rra
	rr	h
	rr	l
	rra
	rr	h
	rr	l
	ret

hex:	defb	"0123456789ABCDEF "
_a:	defs	2
_b:	defs	2
_aa:	defs	2
_bb:	defs	2
_ca:	defs	2
_cb:	defs	2
_i:	defs	2
