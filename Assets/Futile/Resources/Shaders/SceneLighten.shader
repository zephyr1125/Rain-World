// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance


Shader "Futile/SceneLighten" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _MainTex;
//sampler2D _LevelTex;
//sampler2D _DpTex;
//sampler2D _PalTex;
uniform float _BlurDepth;
uniform float2 _MenuCamPos;
uniform float _BlurRange;

sampler2D _GrabTexture : register(s0);

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
   half2 spriteSize = half2(lerp(1, 1400, i.clr.x), lerp(1, 800, i.clr.y));
   float spriteDepth = lerp(0, 10, i.clr.z);

   half dp = 1-tex2D(_MainTex, half2(i.uv.x, i.uv.y/2)).x;

  half2 getPos = half2(i.uv.x, 0.5+i.uv.y/2);
  getPos.x -= (_MenuCamPos.x - i.uv.x) * dp*0.025;
  getPos.y -= (_MenuCamPos.y - i.uv.y) * dp*0.025;
  getPos.y = max(0.5 + 1.0/spriteSize.y, getPos.y);

  half4 texCol = tex2D(_MainTex, getPos);
  half4 grabCol = tex2D(_GrabTexture, half2(i.scrPos.x, 1.0-i.scrPos.y));
     
  return half4(1.0 - (1.0-grabCol.x) * (1.0-texCol.x*texCol.w), 1.0 - (1.0-grabCol.y) * (1.0-texCol.y*texCol.w), 1.0 - (1.0-grabCol.z) * (1.0-texCol.z*texCol.w), i.clr.w);
     

}
ENDCG
				
				
				
			}
		} 
	}
}