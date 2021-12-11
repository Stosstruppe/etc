// Visucal C++ 2019

#include <stdio.h>
#include <Windows.h>

char cells[30000];
char* p = cells;
char* pc;

void jump(int d)
{
	for (int n = 0; ; pc += d) {
		switch (*pc) {
		case '[': n++; break;
		case ']': n--; break;
		}
		if (n == 0) return;
	}
}

int main(int argc, char* argv[])
{
	if (argc != 2) {
		fprintf(stderr, "usage: bfi filename.b\n");
		exit(1);
	}
	HANDLE hFile = CreateFileA(argv[1],
		GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE) {
		fprintf(stderr, "file open error: %s\n", argv[1]);
		exit(1);
	}
	HANDLE hMap = CreateFileMapping(hFile, NULL, PAGE_READONLY, 0, 0, NULL);
	pc = (char*)MapViewOfFile(hMap, FILE_MAP_READ, 0, 0, 0);

	for (; *pc; pc++) {
		switch (*pc) {
		case '>': p++; break;
		case '<': p--; break;
		case '+': (*p)++; break;
		case '-': (*p)--; break;
		case '.': 
			putchar(*p);
			fflush(stdout);
			break;
		case ',': break;
		case '[':
			if (*p == 0) jump(+1);
			break;
		case ']':
			if (*p != 0) jump(-1);
			break;
		}
	}

	BOOL b;
	b = UnmapViewOfFile(pc);
	b = CloseHandle(hMap);
	b = CloseHandle(hFile);
}
