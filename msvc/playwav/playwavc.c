/*
cl /MD /W4 /FAscu playwavc.c
*/
#pragma comment(lib, "winmm")

#include <windows.h>

typedef struct {
	BYTE	RIFF_ckid[4];
	DWORD	RIFF_cksize;
	BYTE	fccType[4];
	BYTE	fmt_ckid[4];
	DWORD	fmt_cksize;
	WORD	wFormatTag;
	WORD	nChannels;
	DWORD	nSamplesPerSec;
	DWORD	nAvgBytesPerSec;
	WORD	nBlockAlign;
	WORD	wBitsPerSample;
	BYTE	data_ckid[4];
	DWORD	data_cksize;
} RIFF;

#define SAMPLE_RATE (48000)
#define DATA_LEN SAMPLE_RATE

int main()
{
	RIFF riff = {
		{'R','I','F','F'}, 36 + DATA_LEN, {'W','A','V','E'},
		{'f','m','t',' '}, 16,
		1, 1, SAMPLE_RATE, SAMPLE_RATE, 1, 8,
		{'d','a','t','a'}, DATA_LEN,
	};
	static BYTE wav[44 + DATA_LEN];
	int f = 0;
	for (int i = 0; i < SAMPLE_RATE; i++) {
		BYTE d = 128 + (f < SAMPLE_RATE/2 ? -10 : 10);
		wav[44 + i] = d;
		f = (f + 880) % SAMPLE_RATE;
	}
	memcpy(wav, &riff, sizeof riff);
	PlaySound((LPCSTR)wav, NULL, SND_MEMORY | SND_SYNC);
}
