// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/WaterLight" //Unlit Transparent Vertex Colored Additive 
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
//sampler2D _PalTex;
//uniform float _fogAmount;
uniform float _waterPosition;

sampler2D _GrabTexture : register(s0);

uniform float _RAIN;

uniform float4 _spriteRect;
uniform float2 _screenSize;
uniform float4 _camInRoomRect;


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
 
 


 half dist = fmod((texcol.x * 255)-1, 30.0)/30.0;

  if(dist < 2.0/30.0 && _waterPosition == 0) return float4(0, 0, 0, 0);
 
 if(dist > 6.0/30.0){
   half4 grabCol = tex2D(_GrabTexture, half2(i.scrPos.x, 1-i.scrPos.y));
  if(grabCol.x != 0 || grabCol.y != 0 || grabCol.z != 0) return float4(0, 0, 0, 0);
 }

 if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0)
 return float4(0, 0, 0, 0);
 
 
 half whatToSine = (_RAIN*6) + (tex2D(_NoiseTex, float2((dist/10)+lerp(textCoord.x, 0.5, dist/3)*2.1,  (_RAIN*0.1)+(dist/5)+lerp(textCoord.y, 0.5, dist/3)*2.1) ).x * 7);
 half col = (sin(whatToSine * 3.14 * 2)*0.5)+0.5;
 
 whatToSine = (_RAIN*2.7) + (tex2D(_NoiseTex, float2((dist/7)+lerp(textCoord.x, 0.5, dist/5)*1.3,  (_RAIN*-0.21)+(dist/8)+lerp(textCoord.y, 0.5, dist/6)*1.3) ).x * 6.33);
 half col2 = (sin(whatToSine * 3.14 * 2)*0.5)+0.5;
 
 col = pow(max(col, col2), 47) * (1-i.uv.y) * pow(tex2D(_NoiseTex, half2(i.uv.x, i.uv.y+_RAIN+dist*0.1)), 2);
 
 col *= tex2D(_MainTex, float2(_camInRoomRect.x + _camInRoomRect.z * i.scrPos.x, _camInRoomRect.y + _camInRoomRect.w * i.scrPos.y)).z;

 if(col < 0.1)  return float4(0, 0, 0, 0);
  
 return half4(1, 1, 1, 0.05 * i.clr.w);
//return half4(col, col, col, 1);
}
ENDCG
				
				
				
			}
		} 
	}
}