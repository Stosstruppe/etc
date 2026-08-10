// cl /O2 /W2 magld.c
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>

typedef unsigned char BYTE;
typedef unsigned short WORD;

#define BUFLEN 30000
#define CW 640
#define CH 400

int LUT[16][2] = {
	{ 0,  0}, {-1,  0}, {-2,  0}, {-4,  0},
	{ 0, -1}, {-1, -1}, { 0, -2}, {-1, -2},
	{-2, -2}, { 0, -4}, {-1, -4}, {-2, -4},
	{ 0, -8}, {-1, -8}, {-2, -8}, { 0,-16}};
BYTE far *planes[4] = {
	(BYTE far *)0xa8000000, (BYTE far *)0xb0000000,
	(BYTE far *)0xb8000000, (BYTE far *)0xe0000000};
BYTE *ppx;

void puttile(int x, int y, BYTE *ptile)
{
	int i;

	outp(0x7c, 0xc0);	// GRCG RMW
	for (i = 0; i < 4; i++) {
		outp(0x7e, *ptile++ * 0x11);
	}
	*(planes[0] + y * 80 + x / 2) = (x & 1) ? 0x0f : 0xf0;
	outp(0x7c, 0x00);	// GRCG off
}

void pixset(int x, int y, WORD pix)
{
	BYTE tiles[4] = {0};
	int i, j;

	// ピクセルからタイルを作る
	for (i = 0; i < 4; i++) {
		for (j = 3; j >= 0; j--) {
			BYTE cy = (pix & 0x8000) ? 1 : 0;
			pix <<= 1;
			tiles[j] = (tiles[j] << 1) | cy;
		}
	}
	puttile(x, y, tiles);
}

void pixcpy(int x, int y, BYTE flg)
{
	BYTE tiles[4];
	int sx = x + LUT[flg][0];
	int sy = y + LUT[flg][1];
	int offset = sy * 80 + sx / 2;
	int i;

	// gvramからタイルを作る
	for (i = 0; i < 4; i++) {
		BYTE t = *(planes[i] + offset);
		tiles[i] = (sx & 1) ? (t & 0x0f) : (t >> 4);
	}
	puttile(x, y, tiles);
}

// フラグ処理
void flgproc(int x, int y, BYTE flg)
{
	if (flg == 0) {
		pixset(x, y, ((WORD)ppx[0] << 8) | ppx[1]);
		ppx += 2;
	} else {
		pixcpy(x, y, flg);
	}
}

// mag処理
void magproc(char *p)
{
	BYTE *pfa, *pfb;
	BYTE flgdats[80] = {0};
	int i, x, y;

	while (*++p) ;	// コメント読み飛ばし

	// ヘッダ領域
	pfa = p + *(WORD *)(p + 12);	// フラグa
	pfb = p + *(WORD *)(p + 16);	// フラグb
	ppx = p + *(WORD *)(p + 24);	// ピクセル

	// パレットデータ
	p += 32;
	for (i = 0; i < 16; i++) {
		outp(0xa8, i);		// パレット番号
		outp(0xaa, *p++ >> 4);	// G
		outp(0xac, *p++ >> 4);	// R
		outp(0xae, *p++ >> 4);	// B
	}

	// フラグデータ
	for (y = 0; y < CH; y++) {
		for (x = 0; x < 80; ) {
			BYTE a = *pfa++;
			for (i = 0; i < 8; i++) {
				BYTE b = 0, f2;
				if (a & 0x80) {
					b = *pfb++;
				}
				flgdats[x] ^= b;
				f2 = flgdats[x];
				flgproc(x*2  , y, (BYTE)(f2 >> 4));
				flgproc(x*2+1, y, (BYTE)(f2 & 0x0f));
				x++;
				a <<= 1;
			}
		}
	}
}

void ginit(void)
{
	_asm {
	mov	ah, 42h		; graphic mode
	mov	ch, 0c0h	; 640x400 color
	int	18h
	mov	ah, 40h		; graphic on
	int	18h
	mov	al, 1		; 16 color
	out	6ah, al
	}
	outp(0x6a, 1);		// 16 color
}

int main(int argc, char *argv[])
{
	FILE *pFile;
	char *buf;

	if (argc != 2) {
		printf("usage: magld hoge.mag\n");
		return 1;
	}
	pFile = fopen(argv[1], "rb");
	if (pFile == NULL) {
		printf("error: fopen\n");
		return 1;
	}
	buf = malloc(BUFLEN);
	if (buf == NULL) {
		return 2;
	}
	fread(buf, 1, BUFLEN, pFile);

	ginit();
	magproc(buf);

	free(buf);
	return 0;
}
