// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/HeatDistortion" //Unlit Transparent Vertex Colored Additive 
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
			GrabPass { }
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


sampler2D _GrabTexture : register(s0);
sampler2D _NoiseTex;
uniform float2 _screenSize;
uniform float4 _spriteRect;
uniform float _RAIN;

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

	float2 textCoord = float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y)/_screenSize.y);

	textCoord.x -= _spriteRect.x;
	textCoord.y -= _spriteRect.y;

	textCoord.x /= _spriteRect.z - _spriteRect.x;
	textCoord.y /= _spriteRect.w - _spriteRect.y;


	half h = (sin((2.5 * _RAIN + tex2D(_NoiseTex, float2(textCoord.x*2.2, _RAIN * - 0.4 + textCoord.y*1.05) ).x * 3) * 3.14 * 2)*0.5)+0.5;
	half h2 = (sin((1.163 * _RAIN + tex2D(_NoiseTex, float2(textCoord.x*1.5, _RAIN * - 0.4 + textCoord.y*0.8782) ).x * 3) * 3.14 * 2)*0.5)+0.5;
	
	
	half2 grabPos = half2(i.scrPos.x, 1.0-i.scrPos.y);
	
	
	half2 distort = half2(lerp(-1, 1, h), lerp(-1, 1, h2));
	
    half amount = clamp(distance(i.uv.xy, half2(0.5, 0.5))*2, 0, 1);
    amount = pow(pow((1-pow(amount , 2)), 3.5), 1);
	
	distort *= 0.0025;
	
	distort *= amount * i.clr.w;
	
	distort.y /= _screenSize.y/_screenSize.x;
	
	grabPos.x += distort.x;
	grabPos.y += distort.y;
	
	grabPos.x = (floor(grabPos.x*_screenSize.x)+0.5)/_screenSize.x;
    grabPos.y = (floor(grabPos.y*_screenSize.y)+0.5)/_screenSize.y;
	
	half4 grabCol = tex2D(_GrabTexture, grabPos);

    return grabCol;
 
 
}
ENDCG
				
				
				
			}
		} 
	}
}