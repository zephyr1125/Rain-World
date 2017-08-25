// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance
Shader "Futile/CicadaWing" 
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
sampler2D _GrabTexture : register(s0);

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
if(tex2D(_MainTex, i.uv).w < 0.5) return half4(0, 0, 0, 0);

//half4 grabTexCol = tex2D(_GrabTexture, half2(i.scrPos.x, 1.0-i.scrPos.y));
//if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0)
//return half4(1, 0, 0, 1);

float2 textCoord = float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y)/_screenSize.y);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;

textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;



//half sincol = (sin((0.8*_RAIN + (tex2D(_NoiseTex, float2(textCoord.x*15, 1.8*_RAIN + textCoord.y*0.2) ).x * 3)) * 3.14 * 2)*0.5)+0.5;

half4 texcol = tex2D(_LevelTex, textCoord);

half grad = fmod((texcol.x * 255)-1, 30.0)/30.0;
  
if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0) grad = 1;
  
  grad = pow(clamp(grad-0.11, 0, 1)*1.17, 2.1);
  
grad = grad * (1.0-i.clr.w);
  


return lerp(half4(i.clr.xyz, 1.0), lerp(tex2D(_PalTex, float2(1.5/32.0, 7.5/8.0)), half4(1, 1, 1, 1), 0.5), grad);

}
ENDCG
				
				
				
			}
		} 
	}
}