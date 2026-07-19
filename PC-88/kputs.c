// zcc +pc88 -create-app -o kputs.bin kputs.c
#include <conio.h>

// 今回のポイント- マンは、オレ一人でやる。
int msg[] = {0x3A23,0x3273,0x244E, 0x255D,0x2524,0x2573,0x2548,
0x2d,0x90,0xb0, 0x255E,0x2573,0x244F,0x2122,
0x252A,0x256C,0x306C,0x3F4D, 0x2447,0x2464,0x246B,0x2123,0};

void vput(int x, int y, char bits) {
	static char *p, b;
	p = (char *)0xc000 + 80 * y + x;
	b = bits;
#asm
	ld	hl, (_st_vput_p)
	ld	a, (_st_vput_b)
	ld	c, $35
	ld	b, $80	; vram
	di
	out	(c), b
	ld	(hl), a
	ld	b, $00	; main ram
	out	(c), b
	ei
#endasm
}

void kput_h(int x, int y, int ka, int steps) {
	for (int i = 0; i < 8; i++) {
		outp(0xe8, ka & 0xff);
		outp(0xe9, ka >> 8);
		vput(x, y, inp(0xe9));
		if (steps & 1) y++;
		steps >>= 1;
		vput(x, y, inp(0xe8));
		if (steps & 1) y++;
		steps >>= 1;
		ka++;
	}
}

void kput_z(int x, int y, int ka, int steps) {
	for (int i = 0; i < 16; i++) {
		outp(0xe8, ka & 0xff);
		outp(0xe9, ka >> 8);
		vput(x  , y, inp(0xe9));
		vput(x+1, y, inp(0xe8));
		if (steps & 1) y++;
		steps >>= 1;
		ka++;
	}
}

int kput(int x, int y, int jc, int steps) {
	int ka, w;
	if (jc < 0x100) {		// 半角文字
		ka = jc << 3;
		kput_h(x, y, ka, steps);
		w = 1;
	} else if (jc < 0x3000) {	// 非漢字
		ka = ((jc & 0x0700)<<1) | ((jc & 0x60)<<7) | ((jc & 0x1f)<<4);
		kput_z(x, y, ka, steps);
		w = 2;
	} else {			// 漢字
		ka = ((jc & 0x1f00)<<1) | ((jc & 0x60)<<9) | ((jc & 0x1f)<<4);
		kput_z(x, y, ka, steps);
		w = 2;
	}
	return w;
}

void kputs(int x, int y, const int *str, int steps) {
	for (int i = 0; str[i]; i++) {
		x += kput(x, y, str[i], steps);
	}
}

void main(void) {
	int x = 30;
	int a = inp(0x32);
	a |= 0x40;
	outp(0x32, a);		// ALU
	outp(0x34, 0x07);	// 白
	kputs(x, 16, msg, 0x7fff);	// 16: 11111111 11111111
	kputs(x, 40, msg, 0x2aaa);	//  8: 22222222
	kputs(x, 56, msg, 0x5b6d);	// 11: 12121212121
}
