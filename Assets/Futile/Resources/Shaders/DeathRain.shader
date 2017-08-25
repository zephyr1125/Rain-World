// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/DeathRain" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _NoiseTex;
//sampler2D _PalTex;
//uniform float _fogAmount;
uniform float _rainDirection;
uniform float _rainEverywhere;
uniform float _rainIntensity;
//sampler2D _ShelterTex;

uniform float _waterLevel;

uniform float _RAIN;
sampler2D _GrabTexture : register(s0);

uniform float4 _RainSpriteRect;



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
   // half2 getPos = half2(i.uv.x*2.0 + _RAIN, (i.uv.y*0.25)+_RAIN*6);
    half2 getPos = half2(i.uv.x*2.0 + _RAIN*0.2, i.uv.y*0.25+_RAIN*3);
  //  float rand = frac(sin(dot(getPos.x, 12.98232)+_RAIN-tex2D(_NoiseTex, half2(getPos.x, _RAIN)).x) * 43758.5453);
  
  half topPos = floor((i.uv.x + _rainDirection*0.05*i.uv.y)*1683)/683.0;
  
  float rand = frac(sin(dot(topPos, 12.98232)+_RAIN-tex2D(_NoiseTex, half2(topPos, _RAIN)).x) * 43758.5453)
  + frac(sin(dot(topPos+1.0/683, 12.98232)+_RAIN-tex2D(_NoiseTex, half2(topPos+1.0/683, _RAIN)).x) * 43758.5453)
  + frac(sin(dot(topPos-1.0/683, 12.98232)+_RAIN-tex2D(_NoiseTex, half2(topPos-1.0/683, _RAIN)).x) * 43758.5453);
  rand /= 3.0;
  
 // float rand = texCol;//frac(dot(0, 12.98232)+ * 43758.5453);

    half displace2 = 0.5 + 0.5f*sin((tex2D(_NoiseTex, half2(i.uv.x*1.3, i.uv.y*0.25+_RAIN*2)).x + _RAIN*5)*6.28);
    half displace = 0.5 + 0.5f*sin((tex2D(_NoiseTex, getPos).x + _RAIN*3 + displace2)*6.28 + i.uv.y*7.0 + _RAIN*46 + getPos.x*4.2*_rainDirection);
   
    
  //  displace = pow(displace * displace2, 0.5);//lerp(displace, displace2, 0.5);
   displace = lerp(displace, displace2, 0.5);
  
   half fac = tex2D(_MainTex, float2(_RainSpriteRect.x + i.uv.x * _RainSpriteRect.z, _RainSpriteRect.y + i.uv.y * _RainSpriteRect.w)).x;
// return half4(fac, fac, fac, 0.5);
  // fac = lerp(fac, 1, _rainEverywhere);
  
   half lightness = (-1 + lerp(displace, rand, 0.5) * 2.0)*fac*pow(_rainIntensity, 0.25);
   
   if(1-rand > _rainIntensity)
   fac = 0;
   else
   fac = max(0, fac-(1-_rainIntensity));
   
   if(rand > 1-_rainEverywhere*1.5) {
   fac = lerp(fac, 1, lerp(displace/5, 1, max(0,_rainEverywhere-0.85)*10));
   lightness = (-1 + lerp(displace, rand, 0.5) * 2.0)*pow(_rainIntensity, 0.1);
   }
  
  if(i.scrPos.y < (1-_waterLevel)-0.14) {
  fac = lerp(fac, 0, clamp((((1-_waterLevel)-0.14) - i.scrPos.y)*5, 0, 1));
  lightness *= fac;
  }

   

  
  // displace *= rand;//lerp(rand, 0, pow(abs(0.5-displace2)*2, 5));
  displace = lerp(displace, rand, 0.8);
 
  
   fac *= _rainIntensity;
   // displace = rand;
    half4 returnCol = tex2D(_GrabTexture, half2(i.scrPos.x - displace*_rainDirection*0.05*rand*displace2*fac, 1-i.scrPos.y - (-0.5+displace)*0.25*fac));
    
    returnCol = lerp(returnCol, half4(0.15*rand, 0.15*rand, 0.15*rand, 1), max(0, _rainEverywhere-0.8)*3);
   
  //  lightness *= rand;
    
    if(lightness < -0.3)
    returnCol.xyz *= 0.9;//1 + lightness;
    else if (lightness > 0.5)
    returnCol.xyz = pow(returnCol.xyz, 0.8);
    
   // return half4(1, 1, 1, 0);
    
    return returnCol;
    
    //return half4(displace, displace, displace, 1);
//    
//    if(lightness>0.7)
//     return half4(1, 1, 1, 1);
//     else
//     return half4(0, 0, 0, 0);
}
ENDCG
				
				
				
			}
		} 
	}
}