// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/VoidCeiling" //Unlit Transparent Vertex Colored Additive 
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
uniform float2 _WorldCamPos;
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

half2 sampleCoord = half2(((i.uv.x / i.clr.x)/i.clr.y + (_WorldCamPos.x/700.0))*0.1 + i.clr.z, i.uv.y);
sampleCoord.y = min(1.0-0.01, sampleCoord.y);


half2 dpOffst = (half2(0.5, 2/3) - i.scrPos);
dpOffst.y /= -2;

half dp = tex2D(_MainTex, sampleCoord).x;

dp = min(1, dp+max(0, ((1.0-i.uv.y)-0.9)*15));

float clds = tex2D(_CloudsTex, half2(sampleCoord.x*35, sampleCoord.y*30 - _RAIN*0.025) + dpOffst*2.21*dp);
float clds2 = tex2D(_CloudsTex, half2(sampleCoord.x*70 * (1.0/i.clr.x), sampleCoord.y*60 + _RAIN*0.018) + dpOffst*lerp(0.1, 0.2, clds)*dp);
if(clds2 > 0.5) clds = 2*clds*clds2;
else clds = 1.0 - 2.0*(1.0-clds)*(1.0-clds2);

half svDp = dp;
if(clds > 0.5) dp = 2*dp*clds;
else dp = 1.0 - 2.0*(1.0-dp)*(1.0-clds);
dp = lerp(svDp, dp, pow(i.uv.y, 3));




half4 texCol = tex2D(_MainTex, sampleCoord  + dpOffst*0.15*dp);
if(clds > 0.5) texCol.x = 2*texCol.x*clds;
else texCol.x = 1.0 - 2.0*(1.0-texCol.x)*(1.0-clds);

half noise = tex2D(_NoiseTex, float2((sampleCoord.x*2+dpOffst.x*0.25*dp)*3, ((sampleCoord.y + clds*0.05)*4+dpOffst.y*0.25*dp)*0.75 - 0.125*_RAIN)).x;
noise = 0.5 + sin(noise*3 * 3.14 * 2 + 0.05*_RAIN)*0.5;
half n2 = tex2D(_NoiseTex, float2((sampleCoord.x*2+dpOffst.x*0.2*dp)*6, ((sampleCoord.y + clds*0.05)*4+dpOffst.y*0.2*dp)*1.5 - 0.175*_RAIN)).x;
noise *= 0.5 + sin(n2*3 * 3.14 * 2 + 0.05*_RAIN)*0.5;
noise = pow(1.0-noise, 4);

clds *= pow(lerp(1, 0.5, noise), 0.4);

dp = clamp((dp-lerp(0.05, 0.15, noise))*1.2, 0, 1);

half3 effCol = tex2D(_PalTex, float2(31.5/32.0, 5.5/8.0)).xyz;

half3 col = lerp(half3(0, 0, 0), half3(0.3,0.3,0.3), round(max(0.01,texCol.x)*max(0.01,clds)*4.0)/4.0);

col = lerp(col, effCol, 1.0-i.uv.y);

effCol = lerp(effCol, half3(0,0,1), pow(i.uv.y, 3)*noise);

col = lerp(col, effCol, round(pow(noise, 10)*3.0)/3.0) * clamp(i.clr.x*1.5+0.05, 0, 1) ;

return half4(col*i.clr.w, round(clamp(pow(dp, lerp(0.01, 0.2, noise)), 0, 1) * 3.0)/3.0);

//return half4(pow(texCol.x*clds, 0.5), 0, pow(noise, 10), round(clamp(pow(dp, lerp(0.2, 0.3, noise)), 0, 1) * 3.0)/3.0);

}



ENDCG
				
				
				
			}
		} 
	}
}