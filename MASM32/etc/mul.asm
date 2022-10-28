comment *
ml /c /coff /Fl /Sa mul.asm
link /subsystem:console mul
*
includelib msvcrt

.386
.model flat

exit proto c :dword
printf proto c :dword, :vararg

.const
msg	db	'[%d]',0ah,0

.data?
a$	dd	?
b$	dd	?
c$	dd	?

.code

mul32 proc c pc$:dword, pa$:dword, pb$:dword
	push	esi
	push	edi

	mov	esi, pa$
	mov	edi, pb$
				; a[0] * b[1]
	mov	ax, [esi]
	mov	cx, [edi+2]
	mul	cx
	push	ax
				; a[1] * b[0]
	mov	ax, [esi+2]
	mov	cx, [edi]
	mul	cx
	push	ax
				; dx:ax = a[0] * b[0]
	mov	ax, [esi]
	mov	cx, [edi]
	mul	cx
	pop	cx
	add	dx, cx
	pop	cx
	add	dx, cx

	mov	edi, pc$
	mov	[edi], ax
	mov	[edi+2], dx

	pop	edi
	pop	esi
	ret
mul32 endp

start proc c
	mov	a$, 100000
	mov	b$, 123
	invoke	mul32, addr c$, addr a$, addr b$
	invoke	printf, addr msg, c$
	invoke	exit, 0
start endp

end start
