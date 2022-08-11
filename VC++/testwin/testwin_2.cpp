#include <Windows.h>
#include <math.h>

void Draw(HWND hWnd, HDC hdc)
{
	static DWORD prev;
	static int count;
	static int fps;
	static float t;

	DWORD tick = GetTickCount();
	if (prev != tick / 1000) {
		prev = tick / 1000;
		fps = count;
		count = 0;
	}
	count++;
	t += .02f;

	//
	RECT rcClt;
	GetClientRect(hWnd, &rcClt);
	FillRect(hdc, &rcClt, HBRUSH(COLOR_BACKGROUND + 1));

	static const POINT pt[]{ {0,0}, {200,0}, {0,200} };
	POINT pt2[3];
	float s = (float)sin(t);
	float c = (float)cos(t);
	for (int i = 0; i < 3; i++) {
		float x = (float)pt[i].x;
		float y = (float)pt[i].y;
		pt2[i].x = rcClt.right / 2 + LONG(x * c - y * s);
		pt2[i].y = rcClt.bottom / 2 - LONG(x * s + y * c);
	}
	Polygon(hdc, pt2, 3);

	WCHAR buf[512];
	int len = wsprintf(buf, L"(%dx%d) fps:%d count:%d",
		rcClt.right, rcClt.bottom, fps, count);
	TextOut(hdc, 0, 0, buf, len);

	//
	PAINTSTRUCT ps;
	HDC hdcWnd = BeginPaint(hWnd, &ps);
	BitBlt(hdcWnd, 0, 0, rcClt.right, rcClt.bottom, hdc, 0, 0, SRCCOPY);
	EndPaint(hWnd, &ps);
}

LRESULT WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	static HDC hdcMem;
	static HBITMAP hBmp;

	switch (uMsg) {
	case WM_PAINT:
		Draw(hWnd, hdcMem);
		return 0;
	case WM_TIMER:
		InvalidateRect(hWnd, nullptr, false);
		return 0;
	case WM_CREATE:
	{
		RECT rc;
		GetClientRect(hWnd, &rc);
		HDC hdc = GetDC(hWnd);
		hdcMem = CreateCompatibleDC(hdc);
		hBmp = CreateCompatibleBitmap(hdc, rc.right, rc.bottom);
		SelectObject(hdcMem, hBmp);
		ReleaseDC(hWnd, hdc);
		SetTimer(hWnd, NULL, 15, nullptr);
		return 0;
	}
	case WM_DESTROY:
		DeleteDC(hdcMem);
		DeleteObject(hBmp);
		PostQuitMessage(0);
		return 0;
	}
	return DefWindowProc(hWnd, uMsg, wParam, lParam);
}

int WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int nShowCmd)
{
	WNDCLASS wc{};
	wc.style = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc = WndProc;
	wc.hInstance = hInstance;
	wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wc.hbrBackground = HBRUSH(COLOR_BACKGROUND + 1);
	wc.lpszClassName = L"testwin";
	if (RegisterClass(&wc) == 0) {
		return 1;
	}

	DWORD dwStyle = WS_OVERLAPPEDWINDOW;
	RECT rc{ 0, 0, 640, 480 };
	AdjustWindowRect(&rc, dwStyle, false);

	HWND hWnd = CreateWindow(
		wc.lpszClassName, L"testwin", dwStyle,
		CW_USEDEFAULT, 0, rc.right - rc.left, rc.bottom - rc.top,
		nullptr, nullptr, hInstance, nullptr);
	if (hWnd == nullptr) {
		return 1;
	}
	ShowWindow(hWnd, nShowCmd);
	UpdateWindow(hWnd);

	MSG msg;
	while (GetMessage(&msg, nullptr, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	return (int)msg.wParam;
}
