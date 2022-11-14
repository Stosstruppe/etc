comment *
ml /c /coff /Fl /Sa sqrt.asm
link /subsystem:console sqrt
*
includelib msvcrt

.386
.model flat

exit proto c :dword
printf proto c :dword, :vararg
scanf proto c :dword, :vararg

.const
fmt	db	'%u', 0
msg	db	'ans=[%u]',0ah,0

.code
sqrt proc c n$:dword
	push	ebx
	mov	ecx, n$		; n
	xor	eax, eax	; ans = 0
	mov	ebx, 40000000h	; bit = 1 << 30
sqrt_loop:
	mov	edx, eax
	shr	eax, 1		; ans >>= 1
	or	edx, ebx	; tmp = (ans << 1) | bit
	cmp	ecx, edx	; if (n >= tmp)
	jb	@f
	sub	ecx, edx	; n -= tmp
	or	eax, ebx	; ans |= bit
@@:
	shr	ebx, 2		; bit >>= 2
	jnz	sqrt_loop
	pop	ebx
	ret
sqrt endp

start proc c
	local x$:dword
start_loop:
	invoke	scanf, addr fmt, addr x$
	cmp	eax, 1
	je	@f
	invoke	exit, 0
@@:
	invoke	sqrt, x$
	invoke	printf, addr msg, eax
	jmp	start_loop
start endp

end start
