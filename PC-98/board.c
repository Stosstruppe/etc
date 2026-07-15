/*
cl /W4 board.c
*/
#include <conio.h>
#include <stdlib.h>

void color(int c, int brg) {
	int i;

	outp(0xa8, c);
	for (i = 0xae; i >= 0xaa; i -= 2) {
		outp(i, brg & 0xff);
		brg >>= 4;
	}
}

void ginit(void) {
	_asm {
	mov	ah, 40h
	int	18h
	mov	ah, 42h
	mov	ch, 0c0h
	int	18h
	}
	outp(0x6a, 1);
	color(0, 0x400);
	color(1, 0xfff);
}

void plroll(void) {
	_asm {
	push	ds
	mov	ax, 0a800h
	mov	ds, ax
	mov	es, ax
	mov	si, 80
	mov	di, 0
	mov	cx, 40 * 400
	cld
	rep movsw
	pop	ds
	}
}

void main(void) {
	char far *p;
	char b;
	int i, t, x;
	long a;

	ginit();
	for (t = 0; ; t++) {
		p = (char far *)0xa8000000 + 80 * 400;
		for (x = 0; x < 640; ) {
			b = 0;
			for (i = 0; i < 8; i++) {
				b <<= 1;
				a = (x-t)^(x+t);
				a = labs(t + a*a*a) % 997;
				if (a < 97) b |= 1;
				x++;
			}
			*p++ = b;
		}
		plroll();
	}
}
