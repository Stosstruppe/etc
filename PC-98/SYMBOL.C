// qcl symbol.c
#include <dos.h>

// Unit Control Work
typedef struct {
	char	onptn;
	char	bcc;
	char	dotu;
	char	dsp;
	char	cpc[4];
	int	sx1;
	int	sy1;
	int	lng1;
	int	wdpa;
	int	rbuf[3];
	int	sx2;
	int	sy2;
	int	mdot;
	int	cir;
	int	lng2;
	char	doti[8];
	char	dtyp;
} UCW;

UCW ucw;

void gput(int x, int y, int s, int c)
{
	_asm {
	push	bx
	mov	ah, 14h
	mov	bx, ds
	mov	cx, offset ucw.doti - 2
	mov	dx, s
	int	18h
	pop	bx
	}

	ucw.onptn = c;
	ucw.dotu = 3;	// set
	ucw.dsp = 2;
	ucw.sx1 = x;
	ucw.sy1 = y;
	ucw.lng1 = 8;
	ucw.lng2 = 8;

	_asm {
	push	bx
	mov	ah, 49h
	mov	ch, 0b0h
	mov	bx, offset ucw
	int	18h
	pop	bx
	}
}

void symbol(int x, int y, const char *p, int z, int c)
{
	outp(0xa2, 0x46);	// zoom
	outp(0xa0, z - 1);

	for ( ; *p; p++) {
		gput(x, y, *p, c);
		x += 8 * z;
	}
}

void main(void)
{
	int i;

	_asm {
	mov	ah, 40h
	int	18h
	mov	ah, 42h
	mov	ch, 0c0h
	int	18h
	}

	for (i = 0; i < 5; i++) {
		symbol(100, 100+50*i, "hello, world", i+1, i+2);
	}
}
