// qcl pal.c

#include <conio.h>

void gcopy(char far *lp, char *p)
{
	int i, j;
	for (i = 0; i < 5 * 100; i++) {
		for (j = 0; j < 16; j++) {
			*lp++ = p[j];
		}
	}
}

int main()
{
	char ab[] = {
		0x00,0xff,0x00,0xff, 0x00,0xff,0x00,0xff,
		0x00,0xff,0x00,0xff, 0x00,0xff,0x00,0xff,
	};
	char ar[] = {
		0x00,0x00,0xff,0xff, 0x00,0x00,0xff,0xff,
		0x00,0x00,0xff,0xff, 0x00,0x00,0xff,0xff,
	};
	char ag[] = {
		0x00,0x00,0x00,0x00, 0xff,0xff,0xff,0xff,
		0x00,0x00,0x00,0x00, 0xff,0xff,0xff,0xff,
	};
	char ai[] = {
		0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00,
		0xff,0xff,0xff,0xff, 0xff,0xff,0xff,0xff,
	};
	char pal[][3] = {
		{0x00,0x00,0x00},
		{0xff,0x00,0x00},
		{0x00,0xff,0x00},
		{0xff,0xff,0x00},

		{0x00,0x00,0x55},
		{0xff,0x00,0x55},
		{0x00,0xff,0x55},
		{0xff,0xff,0x55},

		{0x00,0x00,0xaa},
		{0xff,0x00,0xaa},
		{0x00,0xff,0xaa},
		{0xff,0xff,0xaa},

		{0x00,0x00,0xff},
		{0xff,0x00,0xff},
		{0x00,0xff,0xff},
		{0xff,0xff,0xff},
	};
	int i;

	_asm {
	mov	ah, 40h		; graphic on
	int	18h
	mov	ah, 42h
	mov	ch, 0c0h	; 640x400 color page1
	int	18h
	}

	// T-GDC write mode register 2
	outp(0x6a, 0x01);	// 16 colors

	for (i = 0; i < 15; i++) {
		outp(0xa8, i);
		outp(0xae, pal[i][0]);
		outp(0xac, pal[i][1]);
		outp(0xaa, pal[i][2]);
	}

	gcopy((char far *)0xa8000000, ab);
	gcopy((char far *)0xb0000000, ar);
	gcopy((char far *)0xb8000000, ag);
	gcopy((char far *)0xe0000000, ai);
	return 0;
}
