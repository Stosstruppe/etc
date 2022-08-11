#include <Windows.h>

void Draw(HWND hWnd, HDC hdc)
{
	static DWORD prev;
	static int count;
	static int fps;
	static int t;

	DWORD tick = GetTickCount();
	if (prev != tick / 1000) {
		prev = tick / 1000;
		fps = count;
		count = 0;
	}
	count++;
	t++;

	//
	RECT rcClt;
	GetClientRect(hWnd, &rcClt);

	int cy = rcClt.bottom - 1;
	BitBlt(hdc, 0, 0, rcClt.right, cy, hdc, 0, 1, SRCCOPY);
	for (int x = 0; x < rcClt.right; x++) {
		int a = t + ((x - t) ^ (x + t));
		SetPixel(hdc, x, cy, abs(a * a * a) % 997 < 97 ?
			RGB(255, 255, 255) : RGB(0, 128, 0));
	}

	WCHAR buf[512];
	int len = wsprintf(buf, L"(%dx%d) fps:%d count:%d",
		rcClt.right, rcClt.bottom, fps, count);
	TextOut(hdc, 0, 0, buf, len);

	//
	HDC hdcWnd = GetDC(hWnd);
	BitBlt(hdcWnd, 0, 0, rcClt.right, rcClt.bottom, hdc, 0, 0, SRCCOPY);
	ReleaseDC(hWnd, hdcWnd);
}

LRESULT WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	static HDC hdcMem;
	static HBITMAP hBmp;

	switch (uMsg) {
	case WM_TIMER:
		Draw(hWnd, hdcMem);
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
		SetTimer(hWnd, NULL, 17, nullptr);
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
