// qcl /AL gload.c

#include <stdio.h>

int main()
{
	long gvram[] = { 0xa8000000, 0xb0000000, 0xb8000000 };
	FILE *pf;
	int i;

	// CRT BIOS
	_asm {
	mov	ah, 40h		; graphic on
	int	18h
	mov	ah, 42h
	mov	ch, 0c0h	; 640x400 color page1
	int	18h
	}

	pf = fopen("sample.bin", "rb");
	if (pf == NULL) {
		fprintf(stderr, "fopen\n");
		return 1;
	}
	for (i = 0; i < 3; i++) {
		fread((void *)gvram[i], 32000, 1, pf);
	}
	fclose(pf);
	return 0;
}
