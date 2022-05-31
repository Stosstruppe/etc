//zcc +cpm typing.c -create-app -otyping
#include <stdio.h>

#define M 1000

void sound(unsigned char reg, unsigned char dat)
{
	#asm
	ld	ix, 2
	add	ix, sp
	ld	a, (ix+2)
	out	($a0), a
	ld	a, (ix+0)
	out	($a1), a
	#endasm
}

void main(int argc, char *argv[])
{
	char *p, c;
	int i, j;

	if (argc < 2) return;

	sound(0, 0xac);		// Ch.A L8b
	sound(1, 0x01);		// Ch.A H4b
	sound(6, 16);		// Noise 5b
	sound(7, 0xb6);		// Mixer 10 110 110
	sound(8, 16);		// Ch.A Gain
	sound(11, M & 0xff);	// Envelop L8b
	sound(12, M >> 8);	// Envelop H8b

	for (i = 1; i < argc; i++) {
		p = argv[i];
		while ((c = *p++) > 0x20) {
			putchar(c);
			sound(13, 0);
			for (j = 0; j < 5000; j++) ;
		}
		putchar(' ');
		for (j = 0; j < 5000; j++) ;
	}
}
