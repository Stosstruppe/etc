/*
zcc +msx -lndos -create-app -bnsmile2 smile2.c
zcc +msx -lndos -create-app -subtype=rom -bnsmile2 smile2.c
*/

#include <msx/gfx.h>

#define BYTE unsigned char

main()
{
	BYTE g[] = { 0x3c, 0x42, 0xa5, 0x81, 0xa5, 0x99, 0x42, 0x3c} ;

	set_color(15, 1, 1);
	set_mode(mode_2);

	for (int i = 0; i < MODE2_MAX; i += 8) {
		vwrite(g, i, 8);
	}

	while (1) {
		int c = rand() & 15;
		int addr = (rand() % MODE2_MAX) & ~(7);
		fill(MODE2_ATTR + addr, c << 4, 8);
	}
}
