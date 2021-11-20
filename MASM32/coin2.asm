comment *
ml /c /coff /Fl /Sa coin.asm
link /subsystem:console coin
*

includelib kernel32
includelib winmm

.386
.model flat, stdcall
option casemap: none

include kernel32.inc
include winmm.inc

SAMPLE_RATE	equ	48000
DATA_LEN	equ	SAMPLE_RATE * 11 / 10

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
wavbuf	db	44 + DATA_LEN dup (?)
pData	dd	?

.code

note proc c uses edi, freq:dword, len:dword
	local t:dword, lv:dword

	cld
	mov	edi, pData
	mov	t, 0
	mov	lv, SAMPLE_RATE * 16
	mov	ecx, len
L1:
	push	ecx

	; al = lv / SAMPLE_RATE
	mov	eax, lv
	xor	edx, edx
	mov	ecx, SAMPLE_RATE
	div	ecx
	sub	lv, 16

	; al = 80h + (t < SAMPLE_RATE / 2) ? al : -al
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
	cld
	mov	edi, offset wavbuf
	mov	esi, offset wavhdr
	mov	ecx, 44 / 4
	rep	movsd
	mov	pData, (offset wavbuf) + 44
	invoke	note, 988, SAMPLE_RATE / 10
	invoke	note, 1319, SAMPLE_RATE
	invoke	sndPlaySound, addr wavbuf, 4
	invoke	ExitProcess, 0

end start
