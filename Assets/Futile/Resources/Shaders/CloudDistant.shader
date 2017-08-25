// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/CloudDistant" //Unlit Transparent Vertex Colored Additive 
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


half2 sampleCoord = half2(i.clr.y + i.uv.x - 0.025 * _RAIN * (1-i.clr.x), i.uv.y);
sampleCoord.y = min(1.0-0.01, sampleCoord.y);

half4 mainTexCol = tex2D(_MainTex, sampleCoord);

half dp = mainTexCol.x;
float clds = tex2D(_CloudsTex, half2(sampleCoord.x * 5 * (1.0/i.clr.z) , sampleCoord.y*1.5 + _RAIN*0.025));

if(clds > 0.5) dp = 2*dp*clds;
else dp = 1.0 - 2.0*(1.0-dp)*(1.0-clds);

float col = mainTexCol.y * clamp((dp-0.3)*6.0, 0.5, 1);

half4 returnCol = lerp(pow(tex2D(_PalTex, half2(0.5/32.0, 7.5/8.0)), lerp(1.6, 0.4, round(col*4.0)/4.0)), _AboveCloudsAtmosphereColor, i.clr.x);
returnCol.w = (round((pow(dp, lerp(1.2, 0.05, clds))*1.25 - (1.0-clds)*0.2) * 3.0)/3.0)*i.clr.w;

return returnCol;//half4(dp, dp, dp, 1);

//half2 dpOffst = (half2(0.5, 2/3) - i.scrPos);
//dpOffst.y /= 2;
//
//half h2 = 0.5 - sin((0.07 * _RAIN + tex2D(_NoiseTex, float2(sampleCoord.x*1.5, sampleCoord.y*0.75 + i.clr.y)).x*2) * 3.14 * 2)*0.5;
//half dp = tex2D(_MainTex, sampleCoord + dpOffst*0.05*h2 + half2(0, lerp(-1, 1, h2)*0.01)).x;
//dp -= 0.1 * h2;
//dp =  pow(max(dp-0.15, 0), lerp(0.2, 0.35, h2*h2));
//
//dp = min(1, dp+max(0, ((1.0-i.uv.y)-0.9)*15));
//
//float clds = tex2D(_CloudsTex, half2(sampleCoord.x*5 * (1.0/i.clr.z) , sampleCoord.y*1.5 + _RAIN*0.025) + dpOffst*0.11*dp);
//float clds2 = tex2D(_CloudsTex, half2(sampleCoord.x*8 * (1.0/i.clr.z), sampleCoord.y*2.5 + _RAIN*0.018)*lerp(2,1,sin(i.clr.x*3.14)) + dpOffst*lerp(0.1, 0.2, clds)*dp);
//if(clds2 > 0.5) clds = 2*clds*clds2;
//else clds = 1.0 - 2.0*(1.0-clds)*(1.0-clds2);
//
//if(clds > 0.5) dp = 2*dp*clds;
//else dp = 1.0 - 2.0*(1.0-dp)*(1.0-clds);
//
//
//half4 texCol = tex2D(_MainTex, sampleCoord  + dpOffst*0.15*dp);
//half noise = tex2D(_NoiseTex, float2((sampleCoord.x+dpOffst.x*0.5*dp)*3, (sampleCoord.y+dpOffst.y*0.5*dp)*1.5)).x;//
//noise = 0.5 + sin((0.0025 * _RAIN + noise*2) * 3.14 * 2)*0.5;
//
//float col = pow(texCol.y, lerp(1.4, 0.7, noise)) * clamp((dp-0.3)*6.0, 0.5, 1);
//
//if(col > 0.5) col = 2*col*clds;
//else col = 1.0 - 2.0*(1.0-col)*(1.0-clds);
//
//col = clamp(col*1.4, 0, 1);
//col = lerp(col, 0.5, clamp(((1-i.uv.y)-lerp(0.8, 0.5, noise))*lerp(5, 2, noise), 0, 1));
//
//texCol = lerp(pow(tex2D(_PalTex, half2(0.5/32.0, 7.5/8.0)), lerp(1.6, 0.4, round(col*4.0)/4.0)), _AboveCloudsAtmosphereColor, i.clr.x);
//
//clds = lerp(clds, 1.0, col);
//
//texCol.w = round((pow(dp, lerp(1.2, 0.05, clds))*1.25 - (1.0-clds)*0.2 + noise*0.05) * 3.0)/3.0;

//return texCol;
 

}



ENDCG
				
				
				
			}
		} 
	}
}