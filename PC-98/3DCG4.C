#include <conio.h>
#include <dos.h>
#include <math.h>

#define BASE 256
#define SCALE 2

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

int vtx[] = {
	-1,-1,-1,  1,-1,-1, -1, 1,-1,  1, 1,-1,
	-1,-1, 1,  1,-1, 1, -1, 1, 1,  1, 1, 1,
};
const int idx[] = {
	0,1, 2,3, 4,5, 6,7,
	0,2, 1,3, 4,6, 5,7,
	0,4, 1,5, 2,6, 3,7,
};

int frame = 0;
int pg = 0;
int sint[360];

short idiv(short x, short y)
{
	_asm {
	mov	ax, x
	cwd		; convert word to dword
	mov	dl, ah
	mov	ah, al
	mov	al, 0
	mov	bx, y
	idiv	bx
	mov	x, ax
	}
	return x;
}

short imul(short x, short y)
{
	_asm {
	mov	ax, x
	mov	bx, y
	imul	bx
	mov	al, ah
	mov	ah, dl
	mov	x, ax
	}
	return x;
}

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
	static UCW ucw;
	union REGS iregs, oregs;

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

void draw()
{
	int co, si;
	int mx, my, mz;
	int vx, vy, vz;
	int px[8], py[8];
	int i, v0, v1;
	const int *pv, *pi;

	outp(0xa4, pg);
	pg = 1 - pg;
	outp(0xa6, pg);
	gcls();

	co = sint[(frame+90) % 360];
	si = sint[frame % 360];
	pv = vtx;
	for (i = 0; i < 8; i++) {
		mx = *pv++;
		my = *pv++;
		mz = *pv++;
		vx = imul(mx, co) - imul(mz, si);
		vy = my;
		vz = imul(mx, si) + imul(mz, co);
		vz += 5 * BASE;
		px[i] = 320 + idiv(vx * SCALE, vz);
		py[i] = 200 - idiv(vy * SCALE, vz);
	}

	pi = idx;
	for (i = 0; i < 12; i++) {
		v0 = *pi++;
		v1 = *pi++;
		line(px[v0], py[v0], px[v1], py[v1]);
	}

	frame++;
}

void main()
{
	union REGS iregs, oregs;
	float t;
	int i;

	iregs.h.ah = 0x40;
	int86(0x18, &iregs, &oregs);
	iregs.h.ah = 0x42;
	iregs.h.ch = 0xc0;
	int86(0x18, &iregs, &oregs);

	for (i = 0; i < 24; i++) {
		vtx[i] *= BASE;
	}
	for (i = 0; i < 360; i++) {
		t = i * 3.14159 / 180;
		sint[i] = (int)(sin(t) * BASE);
	}

	while (kbhit() == 0) {
		draw();
	}
}
