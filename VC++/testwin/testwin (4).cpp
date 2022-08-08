#include <Windows.h>

void Render(HWND hWnd, HDC hdc)
{
	static int count = 0;
	static int fps = 0;
	static DWORD prev = 0;
	static DWORD sch = 0;	// scheduled time

	DWORD tick = GetTickCount();
	RECT rc;
	GetClientRect(hWnd, &rc);

	// 背景
	HGDIOBJ br = GetStockObject(GRAY_BRUSH);
	SelectObject(hdc, br);
	Rectangle(hdc, rc.left, rc.top, rc.right, rc.bottom);

	//
	br = GetStockObject(WHITE_BRUSH);
	SelectObject(hdc, br);
	int cx = rc.right * (tick % 1000) / 1000;
	int cy = rc.bottom / 2;
	int r = 100;
	Ellipse(hdc, cx - r, cy - r, cx + r, cy + r);

	// fps表示
	if (prev != tick / 1000) {
		prev = tick / 1000;
		fps = count;
		count = 0;
	}
	count++;

	WCHAR buf[512];
	int c = wsprintf(buf, L"fps:%d count:%d", fps, count);
	TextOut(hdc, 0, 0, buf, c);

	// bit-block transfer
	HDC hdcWnd = GetDC(hWnd);
	BitBlt(hdcWnd, rc.left, rc.top, rc.right, rc.bottom,
		hdc, 0, 0, SRCCOPY);
	ReleaseDC(hWnd, hdcWnd);

	// 待ち
	DWORD msec = 1000 / 60;
	tick = GetTickCount();
	if (sch > tick) {
		Sleep(sch - tick);
		sch += msec;
	}
	else {
		Sleep(1);
		sch = tick + msec;
	}
}

LRESULT WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	PAINTSTRUCT ps;
	HDC hdc;

	switch (uMsg) {
	case WM_PAINT:
		hdc = BeginPaint(hWnd, &ps);
		EndPaint(hWnd, &ps);
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, uMsg, wParam, lParam);
	}
	return 0;
}

int WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int nShowCmd)
{
	WNDCLASS wc{};
	wc.style = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc = WndProc;
	wc.hInstance = hInstance;
	wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wc.hbrBackground = HBRUSH(COLOR_WINDOW + 1);
	wc.lpszClassName = L"testwin";
	if (RegisterClass(&wc) == 0) {
		return 1;
	}

	DWORD dwStyle = WS_OVERLAPPEDWINDOW;
	RECT rc;
	SetRect(&rc, 0, 0, 600, 400);
	AdjustWindowRect(&rc, dwStyle, false);

	HWND hWnd = CreateWindow(
		wc.lpszClassName, L"testwin", dwStyle,
		CW_USEDEFAULT, 0, rc.right - rc.left, rc.bottom - rc.top,
		nullptr, nullptr, hInstance, nullptr);
	if (hWnd == NULL) {
		return 1;
	}
	ShowWindow(hWnd, nShowCmd);

	// bitmapの作成
	GetClientRect(hWnd, &rc);
	HDC hdc = GetDC(hWnd);
	HDC hdcBmp = CreateCompatibleDC(hdc);
	HBITMAP hBmp = CreateCompatibleBitmap(hdc, rc.right, rc.bottom);
	SelectObject(hdcBmp, hBmp);
	ReleaseDC(hWnd, hdc);

	MSG msg{};
	while (msg.message != WM_QUIT) {
		if (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else {
			Render(hWnd, hdcBmp);
		}
	}

	DeleteDC(hdcBmp);
	DeleteObject(hBmp);
	return (int)msg.wParam;
}
