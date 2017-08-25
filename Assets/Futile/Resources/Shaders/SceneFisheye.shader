// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Scene	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance


Shader "Futile/SceneFisheye" //Unlit Transparent Vertex Colored Additive 
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
//uniform float _BlurDepth;
//uniform float2 _MenuCamPos;
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
  
  half2 grabCoord =  half2(i.scrPos.x, 1.0-i.scrPos.y);
  half dst = clamp(distance(half2(0.5, 0.5), grabCoord)/1.4, 0, 1);
  dst = pow(dst, lerp(1, 0.2, dst));
 // dst = max(dst-0.2, 0)*1.5;
  grabCoord += (half2(0.5, 0.5) - grabCoord) * lerp(-0.1, 0.5, pow(dst, 2));
  //grabCoord.x += grabCoord.y*2;
     
  return tex2D(_GrabTexture, grabCoord);
     

}
ENDCG
				
				
				
			}
		} 
	}
}