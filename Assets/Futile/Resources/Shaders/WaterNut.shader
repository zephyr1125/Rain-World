// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/WaterNut" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _PalTex;
sampler2D _LevelTex;
uniform float2 _screenSize;
uniform float4 _spriteRect;
uniform float _waterLevel;

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

half4 texcol = tex2D(_LevelTex, textCoord);

half d = fmod((texcol.x * 255)-1, 30.0)/30.0;
if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0) d = 1.0;

if(d < 6.0/30.0) return half4(0, 0, 0, 0);


     float dist = clamp(1-distance(i.uv.xy, half2(0.5, 0.5))*2, 0, 1);
     if(dist <= 0)
     return half4(0,0,0,0);
     

     half2 dir = normalize(i.uv.xy - half2(0.5, 0.5));
     dir.x *= _screenSize.y / _screenSize.x;

     half2 grabPos = half2(i.scrPos.x, 1-i.scrPos.y) - (dir * 0.01 * sin(dist*3.141592*2));
     grabPos.x = (floor(grabPos.x*_screenSize.x)+0.5)/_screenSize.x;
     grabPos.y = (floor(grabPos.y*_screenSize.y)+0.5)/_screenSize.y;
     
	 half4 grabCol = tex2D(_GrabTexture, grabPos);
	 
	 //float waterProximity = 1-clamp((i.scrPos.y - ((1-_waterLevel) - 0.14))*5, 0, 1);
	 
	 grabCol = lerp(grabCol, half4(i.clr.xyz, 1), (distance(half2(0.4, 0.6), i.uv) > 0.5 ? 0.6 : 0.3));
	 
	 if(distance(half2(0.3, 0.7), i.uv) < 0.15)
	         grabCol = lerp(grabCol, half4(1,1,1,1), 0.6 * i.clr.w);

     return grabCol;
}
ENDCG
				
				
				
			}
		} 
	}
}