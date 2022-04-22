#include <Windows.h>

#define APP_NAME L"EditTest"
#define ID_EDIT 100

HWND hEdit;

void OnCreate(HWND hWnd)
{
	hEdit = CreateWindow(
		L"EDIT", NULL,
		WS_CHILD | WS_VISIBLE | WS_VSCROLL |
		ES_MULTILINE | ES_AUTOVSCROLL,
		0, 0, 0, 0,
		hWnd, (HMENU)ID_EDIT,
		(HINSTANCE)GetWindowLongPtr(hWnd, GWLP_HINSTANCE),
		NULL);

	//HGDIOBJ hFont = GetStockObject(OEM_FIXED_FONT);
	HFONT hFont = CreateFont(
		14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		L"ÇlÇr ÉSÉVÉbÉN");
	SendMessage(hEdit, WM_SETFONT, (WPARAM)hFont, TRUE);

	int tabs[]{ 16 };
	SendMessage(hEdit, EM_SETTABSTOPS, 1, (LPARAM)tabs);
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg) {
	case WM_CREATE:
		OnCreate(hWnd);
		break;
	case WM_SIZE:
		MoveWindow(hEdit,
			0, 0, LOWORD(lParam), HIWORD(lParam), TRUE);
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
