/*
cpm c gload.c
*/
#include <cpm.h>

#define _STROUT 0x09
#define _FOPEN 0x0f

#define FCB 0x005c

char port;
int gvram;

void gput()
{
#asm
	ld	de, 005ch	; FCB
	ld	c, 14h		; _RDSEQ
	call	5
	di
	ld	a, (_port)
	ld	c, a
	out	(c), a
	ld	hl, 0080h	; DTA
	ld	de, (_gvram)
	ld	bc, 128
	ldir
	out	(5fh), a
	ei
#endasm
	gvram += 128;
}

main()
{
	char a;
	int p, i;

	a = bdos(_FOPEN, FCB);
	if (a) {
		bdos(_STROUT, "fopen error\r\n$");
		return;
	}

	outp(0x31, 0x3b);

	for (p = 0; p < 3; p++) {
		port = 0x5c + p;
		gvram = 0xc000;
		for (i = 0; i < 128; i++) {
			gput();
		}
	}

	for (;;) ;
}
