// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/LightSource" //Unlit Transparent Vertex Colored Additive 
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
//sampler2D _PalTex;
//uniform float _fogAmount;
uniform float _waterPosition;

sampler2D _GrabTexture : register(s0);

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

float2 textCoord = float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y)/_screenSize.y);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;
textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;

half4 texcol = tex2D(_LevelTex, textCoord);

int paletteColor = floor(((int)(texcol.x * 255) % 90 )/30.0);
if(texcol.y >= 16.0/255.0) paletteColor = 3;

half dist = fmod((texcol.x * 255)-1, 30.0)/30.0;
if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0) dist = 1.0;


half2 dir = normalize(i.uv.xy - half2(0.5, 0.5)); 

half centerDist = clamp(distance(i.uv.xy, half2(0.5, 0.5)), 0, 0.5);
half2 shadowPos = textCoord - (dir * pow(centerDist, 1.25) * pow(dist, 2) * 0.3);

//half2 highLightPos = textCoord - (dir * lerp(0.002, 0.01, abs((6.0/30.0)-dist)) * pow(sin(centerDist*3.14*2), 0.2));
half2 highLightPos = textCoord - (dir * 0.003 * pow(centerDist*2, 0.25));

half2 oldShadowPos = i.scrPos.xy - (dir * pow(centerDist, 1.25) * pow(dist, 1.5) * 0.3);
oldShadowPos.y = 1-oldShadowPos.y;



texcol = tex2D(_LevelTex, shadowPos);
half shadowDist = fmod((texcol.x * 255)-1, 30.0)/30.0;
if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0) shadowDist = 1.0;

texcol = tex2D(_LevelTex, highLightPos);
half highLightDist = fmod((texcol.x * 255)-1, 30.0)/30.0;
if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0) highLightDist = 1.0;



if (dist > 5.0/30.0){
half4 grabColor = tex2D(_GrabTexture, half2(i.scrPos.x, 1.0-i.scrPos.y));
if( grabColor.x > 1.0/255.0 || grabColor.y != 0.0 || grabColor.z != 0.0) 
return half4(0,0,0,0);
}

if (shadowDist > 5.0/30.0){
half4 grabColor = tex2D(_GrabTexture, oldShadowPos);
if( grabColor.x > 1.0/255.0 || grabColor.y != 0.0 || grabColor.z != 0.0) 
shadowDist = 6.0/30.0;
}


float shadow = dist - shadowDist - (paletteColor == 1 ? 0 : 2.0/30.0);
shadow = pow(clamp(shadow, 0, 1), lerp(1.0-dist, 0.5, 0.5));


float highLight = 0;
if(highLightDist > dist + 0.05) highLight = sin(centerDist*3.14*2);

if(paletteColor == 0){
half2 sd2Pos = textCoord - (dir * 0.01 * centerDist);
float sd2 = fmod((tex2D(_LevelTex, sd2Pos).x * 255)-1, 30.0)/30.0;
if(sd2 < dist && sd2 > dist - 0.1) shadow = lerp(shadow, 1, pow(centerDist*2.0, 2.5-4.0*centerDist));
}

half d = dist;

if(dist < 0.2) dist = pow(1.0-(dist * 5.0), 0.35);
else dist = clamp((dist - 0.2) * 1.3, 0, 1);

dist = 1.0-dist;
dist *= pow(pow((1-pow(centerDist * 2, 2)), 3.5), lerp(0.5, 3.5, d));
 

dist = clamp(lerp(dist, 0, shadow)-shadow*0.3, 0, 1);
if(paletteColor == 0) dist *= 0.8;
else if (paletteColor == 2) dist = pow(dist, 0.8);
else if(paletteColor == 3){
dist *= 0.2;
highLight = 0;
}

dist *= tex2D(_MainTex, i.uv.xy).x;

 return half4(i.clr.xyz, dist * i.clr.w * (0.65 + highLight * 0.35));
}
ENDCG
				
				
			}
		} 
	}
}