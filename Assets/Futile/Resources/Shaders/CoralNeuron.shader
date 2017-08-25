// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/CoralNeuron" //Unlit Transparent Vertex Colored Additive 
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

uniform float _RAIN;

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
half y = (i.uv.y+_RAIN*0.1) * (1.0/i.clr.w) * 0.1;

half h = tex2D(_NoiseTex, half2(i.uv.x*0.2 + _RAIN*2.1, y)).x + y*0.5;
h = 0.5 + sin((h + _RAIN*6) *3.14*2);
h = 1-abs(0.5-h)*2;

half h2 = tex2D(_NoiseTex, half2(i.uv.x*0.5341 + _RAIN*2.1242, -y)).x - y*0.5;
h2 = 0.5 + sin((h2 + _RAIN * 6.21) *3.14*2);
h2 = 1-abs(0.5-h2)*2;

h *= h2;

h *= pow(1-abs(0.5-i.uv.x)*2, 0.2);

//return half4(h, h, h, 1);

//if(h<0.5) h = pow(h, 2);
//else h = pow(h, 0.5);

//h -= sin(y*1.0*3.14)*0.7;

h = 1-abs(0.5-h)*2;

if(h < 0.75) return half4(0,0,0,0);

return half4(i.clr.xyz, lerp(0.5, 0.25, tex2D(_PalTex, half2(30.5/32.0, 7.5/8.0)).x) );



}
ENDCG
				
				
				
			}
		} 
	}
}






















