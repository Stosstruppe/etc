// qcl rdata.c

#include <ctype.h>
#include <dos.h>
#include <stdio.h>

typedef unsigned char BYTE;
typedef unsigned short WORD;

int read_data(BYTE cmd, BYTE daua, WORD len, BYTE secn, BYTE cyl, BYTE head, BYTE secs, BYTE bseg, BYTE boff)
{
	_asm {
	mov	ah, cmd
	mov	al, daua
	mov	bx, len
	mov	ch, secn
	mov	cl, cyl
	mov	dh, head
	mov	dl, secs
	mov	es, bseg
	push	bp
	mov	bp, boff
	int	1bh
	pop	bp
	}
}

int main()
{
	static BYTE buf[1024];
	BYTE far *lp = buf;
	BYTE c;
	int ax, i, j, k;

	ax = read_data(0x76, 0x90, 1024, 3,
		0, 0, 1, FP_SEG(lp), FP_OFF(lp));
	printf("status: %02x\n", ax>>8);
	for (j = 0; j < 16; j++) {
		k = j*16;
		printf("%04x: ", k);
		for (i = 0; i < 16; i++) {
			printf("%02x ", buf[k+i]);
		}
		for (i = 0; i < 16; i++) {
			c = buf[k+i];
			if (! isprint(c)) c = '.';
			putchar(c);
		}
		putchar('\n');
	}
	return 0;
}
