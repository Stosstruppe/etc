#include <Windows.h>

HDC hdcMem;
HBITMAP hBmp;
bool keys[256];

int mx = 320;
int my = 400;

void Draw(HWND hWnd)
{
	static DWORD prev;
	static int count;
	static int fps;
	static DWORD schedule;

	// fps計測
	DWORD tick = GetTickCount();
	if (prev != tick / 1000) {
		prev = tick / 1000;
		fps = count;
		count = 0;
	}
	count++;

	//
	if (keys[VK_LEFT]) mx -= 4;
	if (keys[VK_RIGHT]) mx += 4;

	// クリア
	HDC hdc = hdcMem;
	RECT rcClt;
	GetClientRect(hWnd, &rcClt);
	PatBlt(hdc, 0, 0, rcClt.right, rcClt.bottom, BLACKNESS);

	//
	SelectObject(hdc, GetStockObject(WHITE_BRUSH));
	int r = 20;
	Ellipse(hdc, mx - r, my - r, mx + r, my + r);

	//
	WCHAR buf[512];
	int len = wsprintf(buf, L"(%dx%d) fps:%d count:%d",
		rcClt.right, rcClt.bottom, fps, count);
	TextOut(hdc, 0, 0, buf, len);

	// bit-block transfer
	HDC hdcWnd = GetDC(hWnd);
	BitBlt(hdcWnd, 0, 0, rcClt.right, rcClt.bottom, hdcMem, 0, 0, SRCCOPY);
	ReleaseDC(hWnd, hdcWnd);

	// fps制御
	tick = GetTickCount();
	if (schedule > tick) {
		Sleep(schedule - tick);
		schedule += 17;
	}
	else {
		Sleep(1);
		schedule = tick + 17;
	}
}

LRESULT WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg) {
	case WM_KEYDOWN:
		keys[(WORD)wParam] = true;
		return 0;
	case WM_KEYUP:
		keys[(WORD)wParam] = false;
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
	wc.hbrBackground = (HBRUSH)GetStockObject(NULL_BRUSH);
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

	MSG msg{};
	while (msg.message != WM_QUIT) {
		if (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else {
			Draw(hWnd);
		}
	}
	return (int)msg.wParam;
}
