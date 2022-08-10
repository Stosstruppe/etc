#pragma comment(lib, "d2d1")
#pragma comment(lib, "dwrite")

#include <d2d1_1.h>
#include <dwrite.h>

ID2D1Factory* g_pD2DFactory;
ID2D1HwndRenderTarget* g_pRender;
IDWriteFactory* g_pDWriteFactory;
IDWriteTextFormat* g_pTextFormat;
ID2D1SolidColorBrush* g_pBrushBlack;
ID2D1SolidColorBrush* g_pBrushYellow;

void Init(HWND hWnd)
{
	HRESULT hr;

	// Direct2D
	hr = D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED, &g_pD2DFactory);
	if (FAILED(hr)) return;

	hr = g_pD2DFactory->CreateHwndRenderTarget(
		D2D1::RenderTargetProperties(),
		D2D1::HwndRenderTargetProperties(hWnd, D2D1::SizeU(640, 480)),
		&g_pRender);
	if (FAILED(hr)) return;

	// DirectWrite
	hr = DWriteCreateFactory(DWRITE_FACTORY_TYPE_SHARED,
		__uuidof(g_pDWriteFactory),
		reinterpret_cast<IUnknown**>(&g_pDWriteFactory));
	if (FAILED(hr)) return;

	hr = g_pDWriteFactory->CreateTextFormat(
		L"Verdana", nullptr,
		DWRITE_FONT_WEIGHT_NORMAL,
		DWRITE_FONT_STYLE_NORMAL,
		DWRITE_FONT_STRETCH_NORMAL,
		30, L"", &g_pTextFormat);
	if (FAILED(hr)) return;

	hr = g_pTextFormat->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_LEADING);
	hr = g_pTextFormat->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_NEAR);

	// ブラシ
	hr = g_pRender->CreateSolidColorBrush(D2D1::ColorF(D2D1::ColorF::Black), &g_pBrushBlack);
	hr = g_pRender->CreateSolidColorBrush(D2D1::ColorF(D2D1::ColorF::Yellow), &g_pBrushYellow);
}

void Release()
{
	g_pBrushBlack->Release();
	g_pBrushYellow->Release();

	g_pTextFormat->Release();
	g_pDWriteFactory->Release();
	g_pRender->Release();
	g_pD2DFactory->Release();
}

void Render(HWND hWnd)
{
	static int count = 0;
	static int fps;
	static DWORD prev;

	DWORD tick = GetTickCount();
	if (prev != tick / 1000) {
		prev = tick / 1000;
		fps = count;
		count = 0;
	}
	count++;

	RECT rc;
	GetClientRect(hWnd, &rc);

	WCHAR buf[512];
	int c = wsprintf(buf, L"(%dx%d) fps:%d count:%d",
		rc.right, rc.bottom, fps, count);

	float x = 640 * ((tick % 1000) / 1000.0f);
	D2D1_ELLIPSE ellipse = D2D1::Ellipse(
		D2D1::Point2F(x, 240), 150, 150);

	//
	g_pRender->BeginDraw();
	g_pRender->Clear(D2D1::ColorF(D2D1::ColorF::CornflowerBlue));

	g_pRender->FillEllipse(ellipse, g_pBrushYellow);
	g_pRender->DrawEllipse(ellipse, g_pBrushBlack, 10);
	g_pRender->DrawText(
		buf, c, g_pTextFormat,
		D2D1::RectF(0, 0, 640, 480), g_pBrushBlack);

	g_pRender->EndDraw();
}

LRESULT WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg) {
	case WM_PAINT:
		Render(hWnd);
		ValidateRect(hWnd, nullptr);
		InvalidateRect(hWnd, nullptr, false);
		break;
	case WM_CREATE:
		Init(hWnd);
		break;
	case WM_DESTROY:
		Release();
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
	RECT rc{ 0, 0, 640, 480 };
	AdjustWindowRect(&rc, dwStyle, false);

	HWND hWnd = CreateWindowEx(
		0, wc.lpszClassName, L"testd2d", dwStyle,
		CW_USEDEFAULT, 0, rc.right-rc.left, rc.bottom-rc.top,
		nullptr, nullptr, hInstance, nullptr);
	if (hWnd == nullptr) {
		return 1;
	}
	ShowWindow(hWnd, nShowCmd);

	MSG msg;
	while (GetMessage(&msg, nullptr, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	return (int)msg.wParam;
}
