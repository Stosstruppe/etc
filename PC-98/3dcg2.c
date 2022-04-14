#include <conio.h>
#include <dos.h>
#include <math.h>

#define SCALE 500

typedef unsigned char BYTE;
typedef unsigned short WORD;
typedef struct {
	BYTE gbon_ptn;
	BYTE gbbcc;
	BYTE gbdotu;
	BYTE gbdsp;
	BYTE gbcpc[4];
	WORD gbsx1;
	WORD gbsy1;
	WORD gblng1;
	WORD gbwdpa;
	WORD gbrbuf[3];
	WORD gbsx2;
	WORD gbsy2;
	WORD gbmdot;
	WORD gbcir;
	WORD gblng2;
	WORD gblptn;
	WORD gbdoti[3];
	BYTE gbdtyp;
} UCW;	// Unit Control Work

const float vtx[] = {
	-1,-1,-1,  1,-1,-1, -1, 1,-1,  1, 1,-1,
	-1,-1, 1,  1,-1, 1, -1, 1, 1,  1, 1, 1,
};
const int idx[] = {
	0,1, 2,3, 4,5, 6,7,
	0,2, 1,3, 4,6, 5,7,
	0,4, 1,5, 2,6, 3,7,
};

union REGS iregs, oregs;
UCW ucw;

void gcls()
{
	_asm {
	mov	ax, 0b800h
	mov	es, ax
	xor	ax, ax
	mov	di, ax
	mov	cx, 40 * 400
	cld
	rep stosw
	}
}

void line(int x1, int y1, int x2, int y2)
{
	ucw.gbon_ptn = 4;
	ucw.gbdotu = 3;
	ucw.gbdsp = 0;
	ucw.gbsx1 = (WORD)x1;
	ucw.gbsy1 = (WORD)y1;
	ucw.gbsx2 = (WORD)x2;
	ucw.gbsy2 = (WORD)y2;
	ucw.gblptn = 0xffff;
	ucw.gbdtyp = 1;

	iregs.h.ah = 0x47;
	iregs.h.ch = 0xb0;
	iregs.x.bx = (WORD)&ucw;
	int86(0x18, &iregs, &oregs);
}

void main()
{
	float t, co, si;
	float mx, my, mz;
	float vx, vy, vz;
	int px[8], py[8];
	int i, v0, v1;
	int frame = 0;
	int pg = 0;

	iregs.h.ah = 0x40;
	int86(0x18, &iregs, &oregs);
	iregs.h.ah = 0x42;
	iregs.h.ch = 0xc0;
	int86(0x18, &iregs, &oregs);

	while (kbhit() == 0) {
		outp(0xa4, pg);
		pg = 1 - pg;
		outp(0xa6, pg);
		gcls();

		t = frame++ * (3.14159 / 180);
		co = cos(t);
		si = sin(t);
		for (i = 0; i < 8; i++) {
			mx = vtx[i*3];
			my = vtx[i*3+1];
			mz = vtx[i*3+2];
			vx = mx * co - mz * si;
			vy = my;
			vz = mx * si + mz * co;
			vz += 5;
			px[i] = (int)(320 + vx / vz * SCALE);
			py[i] = (int)(200 - vy / vz * SCALE);
		}
		for (i = 0; i < 12; i++) {
			v0 = idx[i*2];
			v1 = idx[i*2+1];
			line(px[v0], py[v0], px[v1], py[v1]);
		}
	}
}
