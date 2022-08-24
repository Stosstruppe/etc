/*
cpm c gload.c
*/

#include <stdio.h>

char buf[256];
char port;
int gvram;

void ginit()
{
#asm
	ld	a, 3bh
	out	(31h), a
#endasm
}

void gput()
{
#asm
	di
	ld	a, (_port)
	ld	c, a
	out	(c), a
	ld	hl, _buf
	ld	de, (_gvram)
	ld	bc, 256
	ldir
	out	(5fh), a
	ei
#endasm
	gvram += 256;
}

main()
{
	FILE *pf;
	int p, i;

	pf = fopen("test.dat", "rb");
	if (pf == NULL) {
		return;
	}

	ginit();

	for (p = 0; p < 3; p++) {
		port = 0x5c + p;
		gvram = 0xc000;
		for (i = 0; i < 64; i++) {
			fread(buf, 1, 256, pf);
			gput();
		}
	}

	fclose(pf);
	for (;;) ;
}
