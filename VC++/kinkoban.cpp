#include <conio.h>
#include <stdio.h>
#include <windows.h>

#define SCRCLEAR	"\x1b[2J"
#define LOCATE		"\x1b[%d;%dH"

char map[][80] = {
"##########",
"#        #",
"#  $     #",
"#  $  $  #",
"#     $  #",
"#        #",
"##########",
};
int mx = 5, my = 3;

void move(int dx, int dy)
{
	int nx = mx + dx;
	int ny = my + dy;
	if (map[ny][nx] != ' ') return;

	printf(LOCATE, my + 1, mx + 1);
	putchar(' ');
	mx = nx;
	my = ny;
	printf(LOCATE, my + 1, mx + 1);
	putchar('&');
}

int main()
{
	HANDLE hConOut = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleMode(hConOut, 0x7);

	printf(SCRCLEAR);
	printf(LOCATE, 0, 0);
	int height = sizeof map / sizeof map[0];
	for (int y = 0; y < height; y++) {
		printf("%s\n", map[y]);
	}
	printf(LOCATE, my + 1, mx + 1);
	putchar('&');

	while (TRUE) {
		int c = _getch();
		switch (c) {
		case 0x1b: return 0;		// esc
		case 0x48: move(0, -1); break;	// up
		case 0x4b: move(-1, 0); break;	// left
		case 0x4d: move(1, 0); break;	// right
		case 0x50: move(0, 1); break;	// down
		}
	}
}
