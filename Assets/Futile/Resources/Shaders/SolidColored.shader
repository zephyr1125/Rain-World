// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance
Shader "Futile/SolidColored" 
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
uniform float _waterPosition;

struct v2f {
    float4  pos : SV_POSITION;
   float2  uv : TEXCOORD0;
 //  float2 scrPos : TEXCOORD1;
};

float4 _MainTex_ST;

v2f vert (appdata_base v)
{
    v2f o;
    o.pos = UnityObjectToClipPos (v.vertex);
    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
  //  o.scrPos = ComputeScreenPos(o.pos);
    return o;
}



half4 frag (v2f i) : COLOR
{
return half4(i.uv.xy, 0, 1);
//float2 textCoord = float2(floor(i.scrPos.x*1024.0)/1024.0, floor(i.scrPos.y*768.0)/768.0);
//
//textCoord.x -= _spriteRect.x;
//textCoord.y -= _spriteRect.y;
//
//textCoord.x /= _spriteRect.z - _spriteRect.x;
//textCoord.y /= _spriteRect.w - _spriteRect.y;
//
//half rbcol = (sin((_RAIN + (tex2D(_NoiseTex, float2(textCoord.x*1.2, textCoord.y*1.2) ).x * 3) + 0/12.0) * 3.14 * 2)*0.5)+0.5;
//
//float2 distortion = float2(lerp(-0.002, 0.002, rbcol)*lerp(1, 20, pow(i.uv.y, 200)), -0.02 * pow(i.uv.y, 8));
//distortion.x = floor(distortion.x*1024.0)/1024.0;
//distortion.y = floor(distortion.y*768.0)/768.0;
//
//half4 texcol = tex2D(_LevelTex, textCoord+distortion);
//
//
//  half grad = fmod((texcol.x * 255)-1, 30.0)/30.0;
//  
//  if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0)
// grad = 1;
//   
//  if (grad > 6.0/30.0){
//
// half4 grabColor = tex2D(_GrabTexture, half2(i.scrPos.x+distortion.x, 1.0-i.scrPos.y-distortion.y));
//if( grabColor.x != 0.0 || grabColor.y != 0.0 || grabColor.z != 0.0) 
//if (grabColor.x == 1.0/255.0 && grabColor.y == 0.0 && grabColor.z == 0.0)
//grad = 1;
//else{
//grad = 6.0/30.0;
//}
//}
//
//if(_waterPosition < 0.5f && fmod((tex2D(_LevelTex, textCoord).x*255)-1, 30.0)<3.0) return float4(0, 0, 0, 0);
//
//grad = pow(grad, clamp(1-pow(i.uv.y, 10), 0.5, 1));
//
//grad *= i.uv.y;
//
//
//
//    return lerp(tex2D(_PalTex, float2(6.5/32.0, 7.5/8.0)), tex2D(_PalTex, float2(5.5/32.0, 7.5/8.0)), grad);

}
ENDCG
				
				
				
			}
		} 
	}
}