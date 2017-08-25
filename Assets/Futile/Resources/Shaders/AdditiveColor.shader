// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/AdditiveColor" //Unlit Transparent Vertex Colored Additive 
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
//sampler2D _PalTex;
//uniform float _fogAmount;
uniform float _waterPosition;

sampler2D _GrabTexture : register(s0);

//uniform float _RAIN;

uniform float4 _spriteRect;



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

float2 textCoord = float2(floor(i.scrPos.x*1024.0)/1024.0, floor(i.scrPos.y*768.0)/768.0);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;

textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;

half4 texcol = tex2D(_LevelTex, textCoord);



   //int red = texcol.x * 255;
  
 // if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0)
 //red = 30;
   
  // red = fmod(red - 1, 30.0);
  
  
 //half4 setColor = lerp(tex2D(_PalTex, float2(7.5/32.0, 7.5/8.0)), tex2D(_PalTex, float2(8.5/32.0, 7.5/8.0)), i.uv.y);
 //setColor = lerp(setColor, tex2D(_PalTex, float2(1.5/32.0, 7.5/8.0)),i.uv.y*_fogAmount);
 
 //setColor = i.clr;
 if(texcol.x != 1.0 || texcol.y != 1.0 || texcol.z != 1.0)
  if(fmod((texcol.x * 255) - 1, 30.0)/30.0 < i.uv.y + lerp(0.1, -0.1, _waterPosition)) return float4(0, 0, 0, 0);
 
  if (i.uv.y + lerp(0.1, -0.1, _waterPosition) > 6.0/30.0){
   half4 grabColor = tex2D(_GrabTexture, half2(i.scrPos.x, 1.0-i.scrPos.y));
    if( grabColor.x != 0.0 || grabColor.y != 0.0 || grabColor.z != 0.0) 
//setColor.w = 0;
return float4(0, 0, 0, 0);
}


    return i.clr;

}
ENDCG
				
				
				
			}
		} 
	}
}