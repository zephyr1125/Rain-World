// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance
Shader "Futile/WaterFall" 
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

sampler2D _MainTex;
sampler2D _LevelTex;
sampler2D _NoiseTex;
sampler2D _PalTex;
//sampler2D _GrabTexture : register(s0);

uniform float _RAIN;
uniform float4 _spriteRect;
uniform float2 _screenSize;
//uniform float _waterPosition;

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

half sincol = (sin((0.8*_RAIN + (tex2D(_NoiseTex, float2(textCoord.x*15, 1.8*_RAIN + textCoord.y*0.2) ).x * 3)) * 3.14 * 2)*0.5)+0.5;

half4 texcol = tex2D(_LevelTex, textCoord+half2(0, lerp(-0.013, 0.013, sincol)));

half grad = fmod((texcol.x * 255)-1, 30.0)/30.0;
  
if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0) grad = 1;
  
grad = pow(floor(lerp(grad, sincol, 0.2)*10)/10, 0.7);
 
//half edgeCloseness = i.uv.x*10.0;
//if(i.uv.x > 0.5f) edgeCloseness = (1.0-i.uv.x)*10.0;
half edgeCloseness = i.uv.x < 0.5f ? i.uv.x*10.0 : (1.0-i.uv.x)*10.0;
edgeCloseness = min(edgeCloseness, i.uv.y < 0.5f ? i.uv.y*(1.0/i.clr.y) : (1.0-i.uv.y)*(1.0/i.clr.z));

if(lerp(edgeCloseness, sincol, 0.5) < 0.5) return float4(0,0,0,0);
if(sincol < 1-i.clr.x) return float4(0,0,0,0);

return lerp(tex2D(_PalTex, float2(5.5/32.0, 7.5/8.0)), tex2D(_PalTex, float2(4.5/32.0, 7.5/8.0)), grad);

}
ENDCG
				
				
				
			}
		} 
	}
}