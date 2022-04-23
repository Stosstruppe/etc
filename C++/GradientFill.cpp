#pragma comment(lib, "msimg32")

#include <Windows.h>

#define APP_NAME L"HelloWin"

void OnPaint(HWND hWnd)
{
	PAINTSTRUCT ps;
	HDC hdc = BeginPaint(hWnd, &ps);

	RECT rc;
	GetClientRect(hWnd, &rc);
	TRIVERTEX vtx[2]{
		{ 0, 0, 0x0000, 0x0000, 0xffff, 0x0000 },
		{ rc.right, rc.bottom, 0x0000, 0x0000, 0x0000, 0x0000 },
	};
	GRADIENT_RECT mesh{ 0, 1 };
	GradientFill(hdc, vtx, 2, &mesh, 1, GRADIENT_FILL_RECT_V);

	EndPaint(hWnd, &ps);
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg) {
	case WM_PAINT:
		OnPaint(hWnd);
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, uMsg, wParam, lParam);
	}
	return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int nCmdShow)
{
	WNDCLASSEX wc{};
	wc.cbSize = sizeof WNDCLASSEX;
	wc.style = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc = WndProc;
	wc.hInstance = hInstance;
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = HBRUSH(COLOR_WINDOW + 1);
	wc.lpszClassName = APP_NAME;
	if (RegisterClassEx(&wc) == 0) {
		return 0;
	}

	HWND hWnd = CreateWindow(
		APP_NAME, APP_NAME,
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, 0,
		CW_USEDEFAULT, 0,
		NULL, NULL, hInstance, NULL);
	if (hWnd == NULL) {
		return 0;
	}
	ShowWindow(hWnd, nCmdShow);
	UpdateWindow(hWnd);

	MSG msg;
	while (GetMessage(&msg, NULL, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	return msg.wParam;
}
