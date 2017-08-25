// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/VoidWormFin" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _NoiseTex2;
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

half n = tex2D(_NoiseTex, half2(i.clr.y, i.uv.y * lerp(1, 3, i.clr.x)*3));

n = min(1, n + 0.1);
n -= pow(i.uv.x, 1.5);

if(n <= 0)
return half4(0,0,0,0);

half4 texCol = tex2D(_MainTex, half2(i.uv.x * lerp(1, 0.5, i.uv.y), i.uv.y*10));

half d = sin(pow(i.uv.x, 0.4)*3.14);

d -= (1-n) * pow(i.uv.x, 0.5);

d = pow(clamp(d, 0.01, 1), lerp(1.5, 0.5, texCol.x));



d = 0.8*d + 0.2 * texCol.x;

d = floor(d*8.0)/8.0;
d *= clamp((i.uv.y-0.1)*10, 0, 1);
d = 0.5 + 0.5 * d;

//d *= 1.0-i.clr.w;

half r = max(0, pow(i.uv.x - n, 0.5) - max(0, (0.1-i.uv.y)*20));

half3 col = half3(d,d,d);

if(r > 0.4){
	n = tex2D(_NoiseTex2, half2((i.uv.y + i.uv.x*lerp(0.025, -0.05, i.uv.y))*2, (i.uv.y + i.uv.x*lerp(0.025, -0.05, i.uv.y)) * 20));

	if(n - pow((r-0.5)*2, 0.9) <= 0)
	return half4(0,0,0,0);
	
	n =  lerp(n, 1, 1.0-r);
	
	n = floor(n*4.0)/4.0;
	
	col = half3(0.5 +0.5 * n, 0.45 + 0.3*pow(n, 4), 0.45 + 0.3*pow(n, 4));
	
}else if (r > 0.3)
col = lerp(col, half3(0.75 + d*0.25, 0.5 + d*0.25, 0.5 + d*0.25), 0.6);

//return half4(0,0,d*d*d*texCol.x,1);
return half4(lerp(col, half3(0,0,0), i.clr.w), i.clr.x);


}
ENDCG
				
				
				
			}
		} 
	}
}






















