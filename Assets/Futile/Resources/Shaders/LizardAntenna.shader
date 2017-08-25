// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/LizardAntenna" //Unlit Transparent Vertex Colored Additive 
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

//return half4(i.uv.xy, 0, 1);
half y = i.uv.y + random;
y -= floor(y);

if (y > 0.68)
y += abs(y -0.68)*1.25;

y -= floor(y);

half h = tex2D(_NoiseTex, half2(i.uv.x + random, y)).x;
//if(h<0.5) h = pow(h, 1.5);
//else h = pow(h, 0.75);

h -= sin(y*lerp(4.0, 14.0, i.clr.w)*3.14)*0.7;

if(i.uv.y < 0.5)
h -= 1.0 - (i.uv.y * 2);
else
h += i.uv.y/4.0;

//return half4(h,h,h, 1);

if(h < 0.5) return half4(0,0,0,0);

return half4(i.clr.xyz, 1);



}
ENDCG
				
				
				
			}
		} 
	}
}






















