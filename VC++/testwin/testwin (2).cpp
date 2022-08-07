#include <Windows.h>

void Render(HWND hWnd)
{
	static int count = 0;
	static int fps = 0;
	static DWORD prev = 0;
	static DWORD sch = 0;	// scheduled time
	DWORD t = GetTickCount();

	HDC hdc = GetDC(hWnd);

	if (prev != t / 1000) {
		prev = t / 1000;
		fps = count;
		count = 0;
	}
	count++;

	WCHAR buf[512];
	int c = wsprintf(buf, L"fps:%d count:%d", fps, count);
	TextOut(hdc, 0, 0, buf, c);

	ReleaseDC(hWnd, hdc);

	// ‘Ò‚¿
	if (sch > t) {
		Sleep(sch - t);
		sch += 17;
	}
	else {
		Sleep(1);
		sch = t + 17;
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
	HWND hWnd = CreateWindow(
		wc.lpszClassName, L"testwin", dwStyle,
		CW_USEDEFAULT, 0, 640, 480,
		nullptr, nullptr, hInstance, nullptr);
	if (hWnd == NULL) {
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
			Render(hWnd);
		}
	}
	return (int)msg.wParam;
}
