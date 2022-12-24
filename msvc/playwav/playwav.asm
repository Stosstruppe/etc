comment *
ml /c playwav.asm
link /subsystem:console playwav
*
includelib kernel32
includelib winmm

.model flat
NULL equ 0
SND_SYNC equ 0
SND_MEMORY equ 4

SAMPLE_RATE equ 48000
DATA_LEN equ SAMPLE_RATE

ExitProcess proto stdcall :dword
PlaySound proto stdcall :dword,:dword,:dword

.data
RIFF	db	'RIFF'
	dd	36 + DATA_LEN
	db	'WAVE'
fmt	db	'fmt '
	dd	16
wave	dw	1, 1
	dd	SAMPLE_RATE, SAMPLE_RATE
	dw	1, 8
data	db	'data'
	dd	DATA_LEN

.data?
wav$	db	44 + DATA_LEN dup (?)

.code
start proc c
	mov	eax, 0
	mov	edi, offset wav$ + 44
	mov	ecx, DATA_LEN
begin:
	mov	dl, 128 - 10
	cmp	eax, SAMPLE_RATE / 2
	jge	@f
	mov	dl, 128 + 10
@@:
	mov	[edi], dl
	inc	edi
	add	eax, 440
	cmp	eax, SAMPLE_RATE
	jle	@f
	sub	eax, SAMPLE_RATE
@@:
	loop	begin

	mov	esi, offset RIFF
	mov	edi, offset wav$
	mov	ecx, 44 / 4
	cld
	rep movsd

	invoke	PlaySound, addr wav$, NULL, SND_MEMORY or SND_SYNC
	invoke	ExitProcess, 0
start endp

end start
