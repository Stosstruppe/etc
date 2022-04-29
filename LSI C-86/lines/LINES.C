#include <math.h>

void ginit(void);
void line(int, int, int, int, int);

int main()
{
	int i, x, y;
	float t;

	ginit();
	for (i = 0; i < 36; i++) {
		t = (i*10) * (3.14159f/180);
		x = 320 + (int)(cos(t) * 150);
		y = 200 - (int)(sin(t) * 150);
		line(320, 200, x, y, (i%7)+1);
	}
	return 0;
}
