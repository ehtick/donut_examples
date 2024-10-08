/*
* Copyright (c) 2014-2021, NVIDIA CORPORATION. All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a
* copy of this software and associated documentation files (the "Software"),
* to deal in the Software without restriction, including without limitation
* the rights to use, copy, modify, merge, publish, distribute, sublicense,
* and/or sell copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
* DEALINGS IN THE SOFTWARE.
*/

static const float2 g_positions[] = {
	float2(-0.5, -0.5),
	float2(0, 0.5),
	float2(0.5, -0.5)
};

static const float3 g_colors[] = {
	float3(1, 0, 0),
	float3(0, 1, 0),
	float3(0, 0, 1)	
};

struct Constants
{
    uint crashType;
};

#ifdef SPIRV

[[vk::push_constant]] ConstantBuffer<Constants> g_constants;

#else

cbuffer g_constants : register(b0)
{
    Constants g_constants;
};
#endif

RWStructuredBuffer<float> g_buffer : register(u0);

void main_vs(
	uint i_vertexId : SV_VertexID,
	out float4 o_pos : SV_Position,
	out float3 o_color : COLOR
)
{
	o_pos = float4(g_positions[i_vertexId], 0, 1);
	o_color = g_colors[i_vertexId];

	// infinite loop to cause a timeout crash
    if (g_constants.crashType == 1)
    {
        float test = 0.99f;
        while (test < 1.f)
        {
            test *= test;
        }
		// execution will never reach this line, but it is necessary to keep the compiler from optimizing out the loop
		// since otherwise the loop result is never used anywhere
        o_color.r *= test;
    }

	// for page fault crash, if g_buffer is destroyed while this shader is executing, this load should fail
	o_color.r += g_buffer[i_vertexId];
}

void main_ps(
	in float4 i_pos : SV_Position,
	in float3 i_color : COLOR,
	out float4 o_color : SV_Target0
)
{
	o_color = float4(i_color, 1);
}
