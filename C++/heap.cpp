#pragma comment(lib, "winmm")

#include <Windows.h>

#define SAMPLE_RATE 48000
#define DATA_LEN (SAMPLE_RATE / 2)

struct WAVHDR {
	DWORD RIFF_ckid;
	DWORD RIFF_cksize;
	DWORD fccType;
	DWORD fmt_ckid;
	DWORD fmt_cksize;
	WORD  wFormatTag;
	WORD  nChannels;
	DWORD nSamplesPerSec;
	DWORD nAvgBytesPerSec;
	WORD  nBlockAlign;
	WORD  wBitsPerSample;
	DWORD data_ckid;
	DWORD data_cksize;
};

LPBYTE pData;

void note(DWORD freq, DWORD len)
{
	DWORD t = 0;
	BYTE lv = 16;
	for (DWORD i = 0; i < len; i++) {
		*(pData++) = 0x80 + (t < SAMPLE_RATE / 2 ? lv : -lv);
		t = (t + freq) % SAMPLE_RATE;
	}
}

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow)
{
	MEMORYSTATUSEX msx;
	BOOL b = GlobalMemoryStatusEx(&msx);

	HANDLE hHeap = HeapCreate(0, 0, 0);
	LPBYTE lpMem = (LPBYTE)HeapAlloc(hHeap, 0, 44 + DATA_LEN);

	WAVHDR wavhdr = {
		0x46464952, 36 + DATA_LEN, 0x45564157,
		0x20746D66, 16, 1, 1, SAMPLE_RATE, SAMPLE_RATE, 1, 8,
		0x61746164, DATA_LEN
	};
	CopyMemory(lpMem, &wavhdr, 44);
	pData = lpMem + 44;
	note(2000, SAMPLE_RATE / 4);
	note(1000, SAMPLE_RATE / 4);
	b = sndPlaySound((LPCTSTR)lpMem, SND_MEMORY | SND_SYNC);

	b = HeapFree(hHeap, 0, lpMem);
	b = HeapDestroy(hHeap);
}
