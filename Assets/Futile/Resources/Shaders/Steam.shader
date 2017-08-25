// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/Steam" //Unlit Transparent Vertex Colored Additive 
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
//sampler2D _PalTex;
//uniform float _fogAmount;
//uniform float _waterPosition;

sampler2D _GrabTexture : register(s0);

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

float2 textCoord = float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y)/_screenSize.y);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;

textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;

float4 grabTexCol;

//half4 texcol = tex2D(_LevelTex, textCoord);

float dist = clamp(1-distance(i.uv.xy, half2(0.5, 0.5))*2, 0, 1)*pow(i.clr.w, 0.5);
 
 half4 texcol = tex2D(_LevelTex, textCoord);
half dp = fmod((texcol.x * 255), 30.0)/30.0;

if(dp > 6.0/30.0){
grabTexCol = tex2D(_GrabTexture, half2(i.scrPos.x, 1-i.scrPos.y));
if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0)
dp = 6.0/30.0;
}

dp = lerp(dp, 1, pow(i.clr.w, 4));

if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0) dp = 1;
//grad = clamp(grad - 0.2, 0, 1)*1.25;

half h = (sin((dp + 18.5 * _RAIN + tex2D(_NoiseTex, float2(textCoord.x*8.2, _RAIN * - 5.4 + textCoord.y*4.2) ).x * 3) * 3.14 * 2)*0.5)+0.5;



h = lerp(h*dist, lerp(h, 1, 0.8), dist);
h *= i.clr.w;


h *= lerp(dp, 1.0, pow(h, 50*(1.0-dist)));


if(h < 0.35)
return float4(0, 0, 0, 0);


texcol = tex2D(_LevelTex, textCoord + half2(0, (h-0.5)/10.0));
dp = fmod((texcol.x * 255), 30.0)/30.0;

if(dp > 6.0/30.0){
float4 grabTexCol = tex2D(_GrabTexture, half2(i.scrPos.x, 1-i.scrPos.y) + normalize(i.uv.xy - half2(0.5, 0.5))*h/400.0 );
if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0)
dp = 6.0/30.0;
}

//dp = floor(dp*8)/8;
dp = 0.5 + 0.5*dp;
 
 return half4(i.clr.x * dp,i.clr.y * dp,i.clr.z * dp, 1);

}
ENDCG
				
				
				
			}
		} 
	}
}