#pragma comment(lib, "d3d11")
#pragma comment(lib, "d3dcompiler")

#include <d3d11.h>
#include <d3dcompiler.h>
#include <stdio.h>

#define SAFE_RELEASE(p)	{ if (p) { (p)->Release(); (p)=nullptr; } }

const UINT NUM_ELEMENTS = 32;

// 関数プロトタイプ宣言
HRESULT CreateComputeDevice();
HRESULT CreateComputeShader(LPCWSTR pSrcFile, LPCSTR pFunctionName);
HRESULT CreateStructuredBuffer(UINT uElementSize, UINT uCount, void* pInitData,
	ID3D11Buffer** ppBufOut);
HRESULT CreateBufferSRV(ID3D11Buffer* pBuffer, ID3D11ShaderResourceView** ppSRVOut);
HRESULT CreateBufferUAV(ID3D11Buffer* pBuffer, ID3D11UnorderedAccessView** ppUAVOut);
ID3D11Buffer* CreateAndCopyToDebugBuf(ID3D11Buffer* pBuffer);
void RunComputeShader(UINT nNumViews, ID3D11ShaderResourceView** pShaderResourceViews,
	ID3D11UnorderedAccessView* pUnorderedAccessView, UINT X, UINT Y, UINT Z);

// グローバル変数
ID3D11Device* g_pDevice = nullptr;
ID3D11DeviceContext* g_pContext = nullptr;
ID3D11ComputeShader* g_pCS = nullptr;

struct BufType {
	int x;
};

int main()
{
	ID3D11Buffer* pBuf0 = nullptr;
	ID3D11Buffer* pBufResult = nullptr;
	ID3D11ShaderResourceView* pBuf0SRV = nullptr;
	ID3D11UnorderedAccessView* pBufResultUAV = nullptr;

	printf("Creating device...");
	HRESULT hr = CreateComputeDevice();
	if (FAILED(hr)) return 1;
	printf("done\n");

	printf("Creating Compute Shader...");
	hr = CreateComputeShader(L"dx11compute1.hlsl", "CSMain");
	if (FAILED(hr)) return 1;
	printf("done\n");

	// データ
	BufType vBuf0[NUM_ELEMENTS + 1]{};
	for (int i = 0; i < NUM_ELEMENTS; i++) {
		vBuf0[i].x = rand() % 3 + 1;
	}

	//
	CreateStructuredBuffer(sizeof BufType, NUM_ELEMENTS, vBuf0, &pBuf0);
	CreateStructuredBuffer(sizeof BufType, NUM_ELEMENTS, nullptr, &pBufResult);

	CreateBufferSRV(pBuf0, &pBuf0SRV);
	CreateBufferUAV(pBufResult, &pBufResultUAV);

	ID3D11ShaderResourceView* aRViews[] = { pBuf0SRV };
	RunComputeShader(1, aRViews, pBufResultUAV, NUM_ELEMENTS, 1, 1);

	// 結果
	for (int i = 0; i < NUM_ELEMENTS; i++) printf("%d", vBuf0[i].x);
	printf("\n");
	for (int i = 0; i < NUM_ELEMENTS; i++) printf("%d", vBuf0[i + 1].x);
	printf("\n");
	{
		ID3D11Buffer* debugbuf = CreateAndCopyToDebugBuf(pBufResult);
		D3D11_MAPPED_SUBRESOURCE MappedResource;
		g_pContext->Map(debugbuf, 0, D3D11_MAP_READ, 0, &MappedResource);
		BufType* p = (BufType*)MappedResource.pData;
		for (int i = 0; i < NUM_ELEMENTS; i++) {
			printf("%c", p[i].x ? '1' : '0');
		}
		printf("\n");
		g_pContext->Unmap(debugbuf, 0);
		SAFE_RELEASE(debugbuf);
	}

	//
	SAFE_RELEASE(pBuf0SRV);
	SAFE_RELEASE(pBufResultUAV);
	SAFE_RELEASE(pBuf0);
	SAFE_RELEASE(pBufResult);

	SAFE_RELEASE(g_pCS);
	SAFE_RELEASE(g_pContext);
	SAFE_RELEASE(g_pDevice);
}

HRESULT CreateComputeDevice()
{
	D3D_FEATURE_LEVEL flvl[] = {
		D3D_FEATURE_LEVEL_11_1,
		D3D_FEATURE_LEVEL_11_0,
	};
	D3D_FEATURE_LEVEL flOut;

	HRESULT hr = D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr,
		D3D11_CREATE_DEVICE_SINGLETHREADED, flvl, 2, D3D11_SDK_VERSION,
		&g_pDevice, &flOut, &g_pContext);
	return hr;
}

HRESULT CreateComputeShader(LPCWSTR pSrcFile, LPCSTR pFunctionName)
{
	ID3DBlob* pBlob;
	ID3DBlob* pErrorBlob;
	HRESULT hr = D3DCompileFromFile(pSrcFile, nullptr, D3D_COMPILE_STANDARD_FILE_INCLUDE,
		pFunctionName, "cs_5_0", D3DCOMPILE_ENABLE_STRICTNESS, 0, &pBlob, &pErrorBlob);
	if (FAILED(hr)) return hr;

	hr = g_pDevice->CreateComputeShader(
		pBlob->GetBufferPointer(), pBlob->GetBufferSize(), nullptr, &g_pCS);

	SAFE_RELEASE(pErrorBlob);
	SAFE_RELEASE(pBlob);
	return hr;
}

HRESULT CreateStructuredBuffer(UINT uElementSize, UINT uCount, void* pInitData,
	ID3D11Buffer** ppBufOut)
{
	D3D11_BUFFER_DESC desc = {};
	desc.BindFlags = D3D11_BIND_UNORDERED_ACCESS | D3D11_BIND_SHADER_RESOURCE;
	desc.ByteWidth = uElementSize * uCount;
	desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_STRUCTURED;
	desc.StructureByteStride = uElementSize;

	if (pInitData) {
		D3D11_SUBRESOURCE_DATA InitData;
		InitData.pSysMem = pInitData;
		return g_pDevice->CreateBuffer(&desc, &InitData, ppBufOut);
	}
	else {
		return g_pDevice->CreateBuffer(&desc, nullptr, ppBufOut);
	}
}

HRESULT CreateBufferSRV(ID3D11Buffer* pBuffer, ID3D11ShaderResourceView** ppSRVOut)
{
	D3D11_BUFFER_DESC descBuf = {};
	pBuffer->GetDesc(&descBuf);

	D3D11_SHADER_RESOURCE_VIEW_DESC desc = {};
	desc.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
	desc.BufferEx.FirstElement = 0;

	if (descBuf.MiscFlags & D3D11_RESOURCE_MISC_BUFFER_STRUCTURED) {
		desc.Format = DXGI_FORMAT_UNKNOWN;
		desc.BufferEx.NumElements = descBuf.ByteWidth / descBuf.StructureByteStride;
	}
	return g_pDevice->CreateShaderResourceView(pBuffer, &desc, ppSRVOut);
}

HRESULT CreateBufferUAV(ID3D11Buffer* pBuffer, ID3D11UnorderedAccessView** ppUAVOut)
{
	D3D11_BUFFER_DESC descBuf = {};
	pBuffer->GetDesc(&descBuf);

	D3D11_UNORDERED_ACCESS_VIEW_DESC desc = {};
	desc.ViewDimension = D3D11_UAV_DIMENSION_BUFFER;
	desc.Buffer.FirstElement = 0;

	if (descBuf.MiscFlags & D3D11_RESOURCE_MISC_BUFFER_STRUCTURED) {
		desc.Format = DXGI_FORMAT_UNKNOWN;
		desc.Buffer.NumElements = descBuf.ByteWidth / descBuf.StructureByteStride;
	}
	return g_pDevice->CreateUnorderedAccessView(pBuffer, &desc, ppUAVOut);
}

ID3D11Buffer* CreateAndCopyToDebugBuf(ID3D11Buffer* pBuffer)
{
	ID3D11Buffer* debugbuf = nullptr;

	D3D11_BUFFER_DESC desc = {};
	pBuffer->GetDesc(&desc);
	desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
	desc.Usage = D3D11_USAGE_STAGING;
	desc.BindFlags = 0;
	desc.MiscFlags = 0;
	if (SUCCEEDED(g_pDevice->CreateBuffer(&desc, nullptr, &debugbuf))) {
		g_pContext->CopyResource(debugbuf, pBuffer);
	}
	return debugbuf;
}

void RunComputeShader(UINT nNumViews, ID3D11ShaderResourceView** pShaderResourceViews,
	ID3D11UnorderedAccessView* pUnorderedAccessView, UINT X, UINT Y, UINT Z)
{
	g_pContext->CSSetShader(g_pCS, nullptr, 0);
	g_pContext->CSSetShaderResources(0, nNumViews, pShaderResourceViews);
	g_pContext->CSSetUnorderedAccessViews(0, 1, &pUnorderedAccessView, nullptr);

	g_pContext->Dispatch(X, Y, Z);
	g_pContext->CSSetShader(nullptr, nullptr, 0);

	ID3D11UnorderedAccessView* ppUAVnullptr[] = { nullptr };
	g_pContext->CSSetUnorderedAccessViews(0, 1, ppUAVnullptr, nullptr);

	ID3D11ShaderResourceView* ppSRVnullptr[] = { nullptr, nullptr };
	g_pContext->CSSetShaderResources(0, 2, ppSRVnullptr);

	ID3D11Buffer* ppCBnullptr[] = { nullptr };
	g_pContext->CSSetConstantBuffers(0, 1, ppCBnullptr);
}
