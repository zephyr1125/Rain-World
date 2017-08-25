// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/BkgFloor" //Unlit Transparent Vertex Colored Additive 
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
uniform half4 _SceneOrigoPosition;
//uniform float _waterPosition;

sampler2D _GrabTexture : register(s0);

uniform float _RAIN;

uniform float4 _spriteRect;
uniform float2 _screenSize;
uniform float2 _WorldCamPos;


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

float AtmosphereColorAtDepth(in float depth)
{
  return clamp(depth / 15.0, 0, 1)*0.9; //invLerp(4f, 50f, depth) * 0.9f;
}

half4 frag (v2f i) : COLOR
{
float2 textCoord = float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y)/_screenSize.y);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;

textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;

half4 c = tex2D(_LevelTex, textCoord);
if(c.x != 1 && c.y != 1 && c.z != 1) return half4(0,0,0,0);

c = tex2D(_GrabTexture, half2(i.scrPos.x, 1-i.scrPos.y));
if (c.x > 1.0/255.0 || c.y != 0.0 || c.z != 0.0) return half4(0,0,0,0);

half useY = i.uv.y*(1.0-i.clr.y);

float groundDist = (1.0 / (1.0-useY))-1.0;

float2 grabCoord = half2(i.uv.x + (i.uv.x-0.5)*groundDist + _WorldCamPos.x/1400.0, i.uv.y);// pow(i.uv.y, groundDist+1));

c = tex2D(_MainTex, grabCoord);

return half4(lerp(c.xyz, _AboveCloudsAtmosphereColor.xyz, lerp(AtmosphereColorAtDepth(1.0/i.clr.x), AtmosphereColorAtDepth(1.0/i.clr.y), pow(i.uv.y, 12))), c.w);
//return c;//half4(lerp(c.xyz, _AboveCloudsAtmosphereColor.xyz, (1.0 - (1.0/(1.0+i.uv.y)))*0.65), c.w);
}



ENDCG
				
				
				
			}
		} 
	}
}