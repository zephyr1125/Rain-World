// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Futile/WormLayerFade" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _LevelTex;
sampler2D _NoiseTex;
sampler2D _PalTex;
uniform float2 _WorldCamPos;
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
//half h1 = 2.0/3.0 ;
//h1 = 1.0-clamp(h1 - i.uv.y, 0, 1);

//float worldHeight = _WorldCamPos.y / 900.0 + i.uv.y;

//half h2 = (-11000.0/900.0) - worldHeight;
//h2 = 1.0-clamp(h2 - i.uv.y, 0, 1);

//return half4(0, 0, 1, clamp((i.uv.y-h2)/(h2-h1), 0, 1));

//if( abs(i.uv.y - h2) < 0.1) return half4(0, 0, 1, 0.5);
//if( abs(i.uv.y - h1) < 0.1) return half4(1, 0, 0, 0.5);
return tex2D(_PalTex, float2(31.5/32.0, 5.5/8.0));
return half4(tex2D(_PalTex, float2(31.5/32.0, 5.5/8.0)).xyz, i.clr.w);
//return half4(1, 0, 0, max(h1, h2));

}
ENDCG
				
				
				
			}
		} 
	}
}




