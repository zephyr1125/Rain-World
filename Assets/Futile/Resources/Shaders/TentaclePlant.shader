// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/TentaclePlant" //Unlit Transparent Vertex Colored Additive 
{
Properties 
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	}
	
	Category 
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		ZWrite Off
		//Alphatest Greater 0
		Blend SrcAlpha OneMinusSrcAlpha 
		Fog { Color(0,0,0,0) }
		Lighting Off
		Cull Off //we can turn backface culling off because we know nothing will be facing backwards

		BindChannels 
		{
			Bind "Vertex", vertex
			Bind "texcoord", texcoord 
			Bind "Color", color 
		}

		SubShader   
		{
				Pass 
			{
				//SetTexture [_MainTex] 
				//{
				//	Combine texture * primary
				//}
				
				
				
CGPROGRAM
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

//#pragma profileoption NumTemps=64
//#pragma profileoption NumInstructionSlots=2048

//float4 _Color;
sampler2D _MainTex;
//sampler2D _LevelTex;
sampler2D _NoiseTex;
sampler2D _PalTex;

//uniform float _fogAmount;
//uniform float _waterPosition;

//sampler2D _GrabTexture : register(s0);

//uniform float _RAIN;

//uniform float4 _spriteRect;
//uniform float2 _screenSize;

struct v2f {
    float4  pos : SV_POSITION;
   float2  uv : TEXCOORD0;
    float2 scrPos : TEXCOORD1;
    float4 clr : COLOR;
};

float4 _MainTex_ST;

v2f vert (appdata_full v)
{
    v2f o;
    o.pos = UnityObjectToClipPos (v.vertex);
    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
    o.scrPos = ComputeScreenPos(o.pos);
    o.clr = v.color;
    return o;
}



half4 frag (v2f i) : COLOR
{
half random = (i.clr.w * 1000.0) - floor(i.clr.w * 1000.0);

half n = 1-tex2D(_NoiseTex, half2(i.uv.x*0.5 + 0.5*random, i.uv.y*lerp(3, 10, i.clr.w) + random));

//n = min(1, n + 0.1);
//n -= pow(i.uv.x, 1.5);

half dist = abs(i.uv.x - 0.5)*2;
if(i.uv.y > 0.5) dist = distance(i.uv, half2(0.5, 0.5))*2;

//dist = pow(dist, 2);

if(dist > 0.5)
n -= dist-0.5;
else
n = pow(n, dist + 0.5);



if(n < 0.25)
return half4(0,0,0,0);

half clr = 0;

if(pow((n - 0.25) * 1.5, lerp(1, 2, i.uv.y)) < 0.2 * (i.uv.y-0.1))
clr = 1;
else if(pow((n - 0.25) * 1.5, lerp(3, 1, i.uv.y)) < 0.25 * (i.uv.y-0.1))
clr = 0.5;

return lerp(lerp(tex2D(_PalTex, half2(2.5/32.0, 7.5/8.0)), tex2D(_PalTex, half2(3.5/32.0, 7.5/8.0)), pow(i.uv.y, 2)), half4(i.clr.xyz, 1), clr);


}
ENDCG
				
				
				
			}
		} 
	}
}






















