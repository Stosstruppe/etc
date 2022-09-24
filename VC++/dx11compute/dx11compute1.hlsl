struct BufType
{
	int x;
};

StructuredBuffer<BufType> Buffer0 : register(t0);
RWStructuredBuffer<BufType> BufferOut : register(u0);

[numthreads(1, 1, 1)]
void CSMain(uint3 DTid : SV_DispatchThreadID)
{
	uint id = DTid.x;
	BufferOut[id].x = Buffer0[id].x ^ Buffer0[id + 1].x;
}
