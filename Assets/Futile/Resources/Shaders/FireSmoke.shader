// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/FireSmoke" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _LevelTex;
sampler2D _NoiseTex;
sampler2D _NoiseTex2;
//sampler2D _PalTex;
//uniform float _fogAmount;
//uniform float _waterPosition;

//sampler2D _GrabTexture : register(s0);

uniform float _RAIN;

uniform float4 _spriteRect;
uniform float2 _screenSize;


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

float2 textCoord = float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y - _RAIN*153.2)/_screenSize.y);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;

textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;

textCoord.y += 0.04;

float dist = clamp(1-distance(i.uv.xy, half2(0.5, 0.5))*2, 0, 1);
 

half h = (sin((1.77 * _RAIN + tex2D(_NoiseTex, float2(textCoord.x*5.2, _RAIN * 0.1 + textCoord.y*2.6) ).x * 3) * 3.14 * 2)*0.5)+0.5;
   h *= (sin((3.5 * _RAIN + tex2D(_NoiseTex, float2(textCoord.x*12.2, _RAIN * 0.25 + textCoord.y*6.6) ).x * 3) * 3.14 * 2)*0.5)+0.5;
 

h *= 0.5 + 0.5 * sin((tex2D(_NoiseTex, i.uv.xy).x + _RAIN)*6.28*3);
 
   
h = lerp(h*dist, lerp(h, 1, lerp(0.3,0.8,i.clr.w)), dist);

//float rand = ;//frac(sin(dot(textCoord.x, 12.98232)+textCoord.y-tex2D(_NoiseTex, textCoord).x) * 43758.5453);

h -= tex2D(_NoiseTex2, float2(textCoord.x*15.2, _RAIN * 0.1 + textCoord.y*7.6) ).x * lerp(0.7, 0.3, i.clr.w);
 
if(h * i.clr.w < 0.35)
return float4(0, 0, 0, 0);
 
//if(h * i.clr.w > 0.5)
//return half4(i.clr.xyz*0.7,1);
 
return half4(i.clr.xyz,1);

}
ENDCG
				
				
				
			}
		} 
	}
}