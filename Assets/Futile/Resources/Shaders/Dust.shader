// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/Dust" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _CloudsTex;
sampler2D _PalTex;
uniform float _fogAmount;
uniform half4 _AboveCloudsAtmosphereColor;
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

half4 lvlCol = tex2D(_LevelTex, textCoord);
if(lvlCol.x != 1 && lvlCol.y != 1 && lvlCol.z != 1) return half4(0,0,0,0);

half4 grabTexCol = tex2D(_GrabTexture, half2(i.scrPos.x, 1-i.scrPos.y));
if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0) return half4(0,0,0,0);


half2 sampleCoord = half2(i.clr.y + i.uv.x - 0.035 * _RAIN * (1-i.clr.x), i.uv.y);
sampleCoord.y = min(1.0-0.01, sampleCoord.y);

half4 mainTexCol = tex2D(_MainTex, sampleCoord);

half dp = mainTexCol.x;
float clds = tex2D(_CloudsTex, half2(sampleCoord.x * 5 * (1.0/i.clr.z) , sampleCoord.y*1.5 + _RAIN*0.035));

if(clds > 0.5) dp = 2*dp*clds;
else dp = 1.0 - 2.0*(1.0-dp)*(1.0-clds);

dp *= 0.5 - sin((0.32 * _RAIN + tex2D(_NoiseTex, float2(sampleCoord.x, sampleCoord.y*0.25 + i.clr.y)).x*2) * 3.14 * 3)*0.5;

float col = mainTexCol.y * clamp((dp-0.3)*6.0, 0.5, 1);

half4 returnCol = lerp(pow(tex2D(_PalTex, half2(0.5/32.0, 7.5/8.0)), lerp(1.6, 0.4, round(col*4.0)/4.0)), _AboveCloudsAtmosphereColor, i.clr.x);
returnCol.w = (round((pow(dp, lerp(1.2, 0.05, clds))*1.25 - (1.0-clds)*0.2) * 3.0)/3.0)*i.clr.w;



return returnCol;
}



ENDCG
				
				
				
			}
		} 
	}
}