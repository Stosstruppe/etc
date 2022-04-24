comment *
ml /c /coff GradientFill.asm
link /subsystem:windows GradientFill
*
.386
.model flat, stdcall
option casemap:none

include windows.inc
include kernel32.inc
include msimg32.inc
include user32.inc

includelib kernel32.lib
includelib msimg32.lib
includelib user32.lib

.const
APP_NAME	db	'GradientFill', 0

.data
vtx	TRIVERTEX \
	< 0, 0, 00000h, 00000h, 0ffffh, 00000h >, \
	< 0, 0, 00000h, 00000h, 00000h, 00000h >

.code

OnPaint proc hWnd:HWND
	local	ps:PAINTSTRUCT
	local	hdc:HDC
	local	rc:RECT
	local	mesh:GRADIENT_RECT

	invoke	BeginPaint, hWnd, addr ps
	mov	hdc, eax

	invoke	GetClientRect, hWnd, addr rc
	mov	eax, rc.right
	mov	vtx.x[16], eax
	mov	eax, rc.bottom
	mov	vtx.y[16], eax
	mov	mesh.UpperLeft, 0
	mov	mesh.LowerRight, 1
	invoke	GradientFill, hdc, addr vtx, 2, addr mesh, 1, GRADIENT_FILL_RECT_V

	invoke	EndPaint, hWnd, addr ps
	ret
OnPaint endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	cmp	uMsg, WM_PAINT
	jne	@f
	invoke	OnPaint, hWnd
	jmp	@exit
@@:
	cmp	uMsg, WM_DESTROY
	jne	@f
	invoke	PostQuitMessage, 0
	jmp	@exit
@@:
	invoke	DefWindowProc, hWnd, uMsg, wParam, lParam
	ret
@exit:
	xor	eax, eax
	ret
WndProc endp

main proc
	local	hInstance:HINSTANCE
	local	wc:WNDCLASSEX
	local	hWnd:HWND
	local	msg:MSG

	invoke	GetModuleHandle, NULL
	mov	hInstance, eax

	mov	wc.cbSize, sizeof WNDCLASSEX
	mov	wc.style, CS_HREDRAW or CS_VREDRAW
	mov	wc.lpfnWndProc, offset WndProc
	mov	wc.cbClsExtra, 0
	mov	wc.cbWndExtra, 0
	mov	eax, hInstance
	mov	wc.hInstance, eax
	mov	wc.hIcon, 0
	invoke	LoadCursor, NULL, IDC_ARROW
	mov	wc.hCursor, eax
	mov	wc.hbrBackground, COLOR_WINDOW+1
	mov	wc.lpszMenuName, 0
	mov	wc.lpszClassName, offset APP_NAME
	mov	wc.hIconSm, 0
	invoke	RegisterClassEx, addr wc

	invoke	CreateWindowEx,
		0, addr APP_NAME, addr APP_NAME,
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, 0,
		CW_USEDEFAULT, 0,
		NULL, NULL, hInstance, NULL
	mov	hWnd, eax
	invoke	ShowWindow, hWnd, SW_SHOW
	invoke	UpdateWindow, hWnd
@@:
	invoke	GetMessage, addr msg, NULL, 0, 0
	or	eax, eax
	jz	@f
	invoke	TranslateMessage, addr msg
	invoke	DispatchMessage, addr msg
	jmp	@b
@@:
	invoke	ExitProcess, msg.wParam
main endp

end main
