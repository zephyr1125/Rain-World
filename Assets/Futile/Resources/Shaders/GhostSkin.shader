// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/GhostSkin" //Unlit Transparent Vertex Colored Additive 
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

half2 getPos = half2((i.uv.x - 0.5 - lerp(-1, 1, i.clr.y))*lerp(0.05, 1, i.clr.x), i.uv.y*2.7);
//getPos.x -= ;
getPos.x = floor(getPos.x*32.0)/32.0;
getPos.y = floor(getPos.y*64.0)/64.0;

half4 texCol = tex2D(_MainTex, getPos);

//int hello = (int)(texCol.x * 256.0);

half glimmer = 0;
if(texCol.x > 0) 
//glimmer = frac(texCol.x*7343.5434 + cos(texCol.x *2.2)*3.2) * 0.6 + 0.4*sin((texCol.x*232.4231 + i.clr.y + _RAIN*0.02)*72.2);
glimmer = tex2D(_NoiseTex2, half2(texCol.x, _RAIN*0.02 + i.clr.y*0.2 + i.clr.w*0.3)).x;
glimmer = max(0, glimmer - i.clr.z);

return lerp(tex2D(_PalTex, half2(2.5/32.0, 7.5/8.0)), half4(0.529, 0.365, 0.184, 1), glimmer);

return half4(glimmer, 0, 0, 1);

}



ENDCG
				
				
				
			}
		} 
	}
}