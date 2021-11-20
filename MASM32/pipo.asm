comment *
ml /c /coff /Fl /Sa pipo.asm
link /subsystem:windows pipo
*

includelib kernel32
includelib winmm

.386
.model flat, c
option casemap: none

include kernel32.inc
include winmm.inc

SAMPLE_RATE	equ	48000
DATA_LEN	equ	SAMPLE_RATE / 2

.data
wavhdr	db	'RIFF'
	dd	36 + DATA_LEN
	db	'WAVE'
	db	'fmt '
	dd	16
	dw	1
	dw	1
	dd	SAMPLE_RATE
	dd	SAMPLE_RATE
	dw	1
	dw	8
	db	'data'
	dd	DATA_LEN

.data?
hHeap	dd	?
pMem	dd	?
pData	dd	?

.code

note proc c uses edi, freq:dword, len:dword
	local t:dword

	cld
	mov	edi, pData
	mov	t, 0
	mov	ecx, len
L1:
	push	ecx

	; al = 80h + (t < SAMPLE_RATE / 2) ? al : -al
	mov	al, 16
	cmp	t, SAMPLE_RATE / 2
	jb	@f
	neg	al
@@:
	add	al, 80h
	stosb

	; t = (t + freq) % SAMPLE_RATE
	mov	eax, t
	add	eax, freq
	xor	edx, edx
	mov	ecx, SAMPLE_RATE
	div	ecx
	mov	t, edx

	pop	ecx
	loop	L1

	mov	pData, edi
	ret
note endp

start:
	invoke	HeapCreate, 0, 0, 0
	mov	hHeap, eax
	invoke	HeapAlloc, hHeap, 0, 44 + DATA_LEN
	mov	pMem, eax

	cld
	mov	edi, pMem
	mov	esi, offset wavhdr
	mov	ecx, 44 / 4
	rep movsd
	mov	pData, edi
	invoke	note, 2000, SAMPLE_RATE / 4
	invoke	note, 1000, SAMPLE_RATE / 4
	invoke	sndPlaySound, pMem, 4

	invoke	HeapFree, hHeap, 0, pMem
	invoke	HeapDestroy, hHeap
	invoke	ExitProcess, 0

end start
