// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/MapAerial" //Unlit Transparent Vertex Colored Additive 
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
		//GrabPass { }
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
sampler2D _mapFogTexture;
//sampler2D _NoiseTex;
//sampler2D _PalTex;
//uniform float _fogAmount;
//uniform float _waterPosition;

//sampler2D _GrabTexture : register(s0);

uniform float _RAIN;

//uniform float4 _spriteRect;
uniform float2 _screenSize;
uniform float2 _mapSize;
uniform float2 _mapPan;
uniform half4 _MapCol;

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


float dst = clamp(distance(i.scrPos, half2(0.5, 0.5)), 0, 1);
half2 displace = normalize(i.scrPos-half2(0.5, 0.5)) * (1-dst)*pow(dst,lerp(4,6,dst))*2;
displace.y *= 0.5 / 3.0;
displace.x /= _mapSize.x / 500; 
displace.y /= _mapSize.y / 500; 

float h = 0.5;
if(i.clr.z == 0) h = 0;
else if (i.clr.z == 1) h = 1;


half2 grabPos = half2(_mapPan.x + (i.uv.x - 0.5) * (_screenSize.x / _mapSize.x) / lerp(3.25, 4.75, i.clr.y), (_mapPan.y / 3.0) +  ((2.0*h)/3.0) + ((i.uv.y - 0.5)  * (_screenSize.y / _mapSize.y) / lerp(3.25, 4.75, i.clr.y)) / 3.0);
grabPos -= displace;

if(grabPos.y < lerp(0.0, 2.0, h)/3.0) grabPos.y = lerp(0.0, 2.0, h)/3.0;
else if(grabPos.y > lerp(1.0, 3.0, h)/3.0) grabPos.y = lerp(1.0, 3.0, h)/3.0;

half4 grabCol = tex2D(_MainTex, grabPos);

//if(grabCol.y > 0.5 || tex2D(_mapFogTexture, grabPos).x < 0.5) return half4(0,0,0,0.7 * i.clr.w * (1.0 - i.clr.x));
if(grabCol.y > 0.5 || tex2D(_mapFogTexture, grabPos).x < 0.5) return half4(0.25,0.25,0.25,0.4 * i.clr.w * (1.0 - i.clr.x));

float lght = grabCol.x;

if(lght >= 0.3 && lght <= 0.7 && grabCol.y == 0)
return half4(1,1,1,1 * i.clr.w);
else if(lght < 0.3){
	if(tex2D(_mapFogTexture, grabPos).x < 0.54)
	return half4(_MapCol.xyz, i.clr.w);
	else
return half4(0,0,0,0.7 * i.clr.w * (1.0 - i.clr.x));
}
else if(grabCol.z > grabCol.x*lerp(0.5, 0.9, sin((grabPos.x - (_RAIN*75/_mapSize.x))*_mapSize.x*0.25))) 
return half4(0.05,0.05,0.8,i.clr.w*lerp(0.5, 0.1, i.clr.x));
else {
//	if(tex2D(_mapFogTexture, grabPos).x < 0.54)
//	return half4(0,0,1,i.clr.w);
//	else
	return half4(0.25,0.25,0.25,0.4 * i.clr.w * (1.0 - i.clr.x));
}
}
ENDCG
				
				
			}
		} 
	}
}















