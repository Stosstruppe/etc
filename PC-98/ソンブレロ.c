typedef unsigned char BYTE;
typedef unsigned short WORD;

int hoge(int x, int y) {
	int res[2];
	asm("\
	jmp	hoge1			\n\
DR	dd	0.01745	; 3.14/180	\n\
N100	dw	100			\n\
N30	dw	30			\n\
N3	dw	3			\n\
hoge1:					\n\
		; r = dr * sqrt(x * x + y * y)	\n\
	fild	word [bp+4]	; x	\n\
	fmul	st0, st0		\n\
	fild	word [bp+6]	; y	\n\
	fmul	st0, st0		\n\
	faddp	st1, st0		\n\
	fsqrt				\n\
	fmul	dword cs:[DR]		\n\
	fstp	dword [bp-4]		\n\
		; z = 100 * cos(r) - 30 * cos(3 * r)	\n\
	fld	dword [bp-4]	; r	\n\
	fcos				\n\
	fimul	word cs:[N100]		\n\
	fld	dword [bp-4]	; r	\n\
	fimul	word cs:[N3]		\n\
	fcos				\n\
	fimul	word cs:[N30]		\n\
	fsubp	st1, st0		\n\
	fistp	word [bp-4]		\n\
	");
	return res[0];
}

void vpoke(WORD p, BYTE b) {
	asm("\
	mov	ax, 0b800h	\n\
	mov	es, ax		\n\
	mov	di, [bp+4]	\n\
	mov	al, [bp+6]	\n\
	or	es:[di], al	\n\
	");
}

void pset(int x, int y) {
	vpoke(y * 80 + x / 8, 0x80 >> (x & 7));
}

void main() {
	asm("\
	mov	ah, 40h		\n\
	int	18h		\n\
	mov	ah, 42h		\n\
	mov	ch, 0c0h	\n\
	int	18h		\n\
	mov	al, 1		\n\
	out	6ah, al		\n\
	");
	int d[640];
	for (int i = 0; i < 640; i++) {
		d[i] = 400;
	}
	for (int y = -180; y <= 180; y += 4) {
		for (int x = -180; x <= 180; x += 4) {
			int z = hoge(x, y);
			int sx = 320 + x - y / 2;
			int sy = 160 - y / 2 - z;
			if (d[sx] > sy) {
				d[sx] = sy;
				pset(sx, sy);
			}
		}
	}
}
