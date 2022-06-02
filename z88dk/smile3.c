/*
zcc +msx -subtype=msxdos -osmile3.com smile3.c
*/

#include <msx/gfx.h>

typedef unsigned char BYTE;
//#define BYTE unsigned char

main()
{
	BYTE g[] = { 0x3c, 0x42, 0xa5, 0x81, 0xa5, 0x99, 0x42, 0x3c };

	set_color(15, 1, 1);
	set_mode(mode_2);

	for (int i = 0; i < MODE2_MAX; i += 8) {
		vwrite(g, i, 8);
	}

	while (! get_trigger(0)) {
		int c = rand() & 15;
		int addr = (rand() % MODE2_MAX) & ~(7);
		fill(MODE2_ATTR + addr, c << 4, 8);
	}

	set_mode(mode_1);
}
