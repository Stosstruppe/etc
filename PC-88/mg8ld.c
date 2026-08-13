/*
zcc +pc88 -create-app -o mg8ld.bin mg8ld.c
*/
#include <stdlib.h>

typedef unsigned char BYTE;
typedef unsigned short WORD;

// ピクセル参照テーブル
int LUT[4][2] = {{0,0}, {-1,0}, {0,-1}, {0,-2}};

BYTE *ppx;	// ピクセルデータ

BYTE peek(BYTE *p)
{
#asm
	pop	de
	pop	hl	; p
	push	de
	push	de
	ld	a, h
	out	($70), a
	ld	h, $80
	ld	l, (hl)
	ld	h, 0
#endasm
}

void pixset(int x, int y) {
	BYTE *p = 0xc000 + y * 80 + x;
#asm
	di
#endasm
	for (int i = 0; i < 3; i++) {
		outp(0x5c + i, 0);
		*p = peek(ppx++);
	}
	outp(0x5f, 0);
#asm
	ei
#endasm
}

void pixcpy(int x, int y, BYTE flg) {
	int *t = LUT[flg];
	BYTE *pd = 0xc000 + y * 80 + x;
	BYTE *ps = 0xc000 + (y + t[1]) * 80 + (x + t[0]);
#asm
	di
#endasm
	outp(0x32, 0xe9);	// ALU
	*pd = *ps;
	outp(0x32, 0xa9);	// 独立
#asm
	ei
#endasm
}

// フラグ処理
void flgproc(int x, int y, BYTE flg)
{
	if (flg == 0) {
		pixset(x, y);
	} else {
		pixcpy(x, y, flg);
	}
}

void main(void)
{
	BYTE *p = 0x1000;
	outp(0x35, 0x90);	// gvram r/w
	outp(0x31, 0x3b);	// all ram

	// コメント読み飛ばし
	while (*++p) ;

	// ヘッダ部
	BYTE *pfa = p + *(WORD *)(p + 12);	// フラグa
	BYTE *pfb = p + *(WORD *)(p + 16);	// フラグb
	ppx = p + *(WORD *)(p + 24);		// ピクセルデータ

	// パレットデータ

	outp(0x31, 0x39);	// rom/ram

	// フラグデータ
	BYTE flgdat[20] = {0};
	int x = 0, y = 0;
	for (int i = 0; i < 500; i++) {
		BYTE a = peek(pfa++);
		for (int j = 0; j < 8; j++) {
			BYTE b = 0;
			if (a & 0x80) {
				b = peek(pfb++);
			}
			flgdat[x] ^= b;
			BYTE f = flgdat[x];
			for (int k = 0; k < 4; k++) {
				flgproc(x*4+k, y, (f>>(6-k*2)) & 3);
			}
			if (++x >= 20) {
				x = 0;
				y++;
			}
			a <<= 1;
		}
	}
}
