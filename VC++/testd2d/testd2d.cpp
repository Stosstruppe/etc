#pragma comment(lib, "d2d1")

#include <d2d1_1.h>

ID2D1Factory* d2d1Factory;
ID2D1HwndRenderTarget* renderTarget;
ID2D1SolidColorBrush* brush;

void Initialize(HWND hWnd)
{
	HRESULT hr;

	hr = D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED, &d2d1Factory);
	if (FAILED(hr)) {
		return;
	}

	D2D1_RENDER_TARGET_PROPERTIES rtp{};
	rtp.type = D2D1_RENDER_TARGET_TYPE_DEFAULT;
	rtp.pixelFormat.format = DXGI_FORMAT_UNKNOWN;
	rtp.pixelFormat.alphaMode = D2D1_ALPHA_MODE_UNKNOWN;
	rtp.usage = D2D1_RENDER_TARGET_USAGE_NONE;
	rtp.minLevel = D2D1_FEATURE_LEVEL_DEFAULT;

	D2D1_HWND_RENDER_TARGET_PROPERTIES hrtp{};
	hrtp.hwnd = hWnd;
	hrtp.pixelSize.width = 640;
	hrtp.pixelSize.height = 480;
	hrtp.presentOptions = D2D1_PRESENT_OPTIONS_NONE;

	hr = d2d1Factory->CreateHwndRenderTarget(&rtp, &hrtp, &renderTarget);
	if (FAILED(hr)) {
		return;
	}

	D2D1_COLOR_F c = { 1, 0, 0, 1 };
	hr = renderTarget->CreateSolidColorBrush(c, &brush);
}

void Exiting()
{
	brush->Release();
	renderTarget->Release();
	d2d1Factory->Release();
}

void Draw()
{
	renderTarget->BeginDraw();
	D2D1_COLOR_F c = { 0, 0, .5f, 1 };
	renderTarget->Clear(c);
	D2D1_RECT_F rc = { 100, 100, 200, 200 };
	renderTarget->DrawRectangle(rc, brush, 10);
	renderTarget->EndDraw();
}

LRESULT WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg)	{
	case WM_PAINT:
		Draw();
		ValidateRect(hWnd, nullptr);
		break;
	case WM_CREATE:
		Initialize(hWnd);
		break;
	case WM_DESTROY:
		Exiting();
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, uMsg, wParam, lParam);
	}
	return 0;
}

int WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int nShowCmd)
{
	WNDCLASSEX wc{};
	wc.cbSize = sizeof wc;
	wc.style = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc = WndProc;
	wc.hInstance = hInstance;
	wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wc.hbrBackground = HBRUSH(COLOR_BACKGROUND + 1);
	wc.lpszClassName = L"testd2d";
	if (RegisterClassEx(&wc) == 0) {
		return 1;
	}

	DWORD dwStyle = WS_OVERLAPPEDWINDOW;

	HWND hWnd = CreateWindowEx(
		WS_EX_LEFT, wc.lpszClassName, L"testd2d", dwStyle,
		CW_USEDEFAULT, 0, 640, 480,
		nullptr, nullptr, hInstance, nullptr);
	if (hWnd == nullptr) {
		return 1;
	}
	ShowWindow(hWnd, nShowCmd);

	while (true) {
		MSG msg;
		int r = GetMessage(&msg, nullptr, 0, 0);
		if (r > 0) {
			DispatchMessage(&msg);
		}
		else {
			return (int)msg.wParam;
		}
	}
}
