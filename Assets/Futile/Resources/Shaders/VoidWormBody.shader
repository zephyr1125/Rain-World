// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/VoidWormBody" //Unlit Transparent Vertex Colored Additive 
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
//sampler2D _LevelTex;
sampler2D _NoiseTex;
sampler2D _PalTex;

//uniform float _fogAmount;
//uniform float _waterPosition;

//sampler2D _GrabTexture : register(s0);

uniform float _RAIN;

//uniform float4 _spriteRect;
//uniform float2 _screenSize;

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

half jagg = tex2D(_NoiseTex, half2(i.uv.y*lerp(300, 900, i.clr.z) + i.clr.w * (i.uv.x < 0.5 ? -1 : 1) * 0.2, ((i.uv.y * lerp(3, 1, pow(i.uv.y, 0.5))) + i.clr.w) * 30)) * min(i.uv.y+0.1, 1);
jagg -= pow(1-abs(i.uv.x - 0.5)*2, 0.15)*1.5;

if(jagg > 0)
return half4(0,0,0,0);

half h = pow(i.uv.y, 1.0 + sin(i.uv.y*3.14)) * lerp(30, 100, i.clr.z);

h = frac(h);

half d = 1.0 - abs(0.5-i.uv.x)*2;
d *= 1.0-jagg;
d = pow(d, 0.2);

d -= 0.2+pow(abs(h-0.5)*2, 3)*0.6;
if(d < 0) return half4(0,0,0,0);

d = pow(d, lerp(0.5, 1.5, tex2D(_MainTex, half2(i.uv.x, i.uv.y*lerp(90, 150, i.clr.z))).x));
d = floor(d*8.0)/8.0;
d = clamp(0.5 + 0.5*d, 0, 1);

d *= 1.0-i.clr.w;

half l = tex2D(_MainTex, half2(i.uv.x+i.uv.y*5, i.uv.y*lerp(60, 140, i.clr.z))).z * pow(1.0-abs(0.5-i.uv.x)*2, 0.2);

half light = (0.5 + 0.5 * sin((tex2D(_NoiseTex, half2(i.uv.x, i.uv.y * 40 + _RAIN*10)).x * 5 + _RAIN*10 + i.uv.y)  * 3.14 )) * pow(abs(frac(i.uv.y*3 + _RAIN*2)-0.5) * 2, 0.5);
light = clamp(light + max(i.uv.y-0.92, 0)*20, 0, 1);
light = floor(light*l*6.0)/6.0;
//if(light > 0.75) return half4(0,0,1,1);
d *= lerp(1, 0.9, l);

half y = max(0, tex2D(_MainTex, half2(i.uv.x, i.uv.y*lerp(90, 150, i.clr.z))).y * abs(i.uv.x-i.clr.y) * 1-pow(abs(h-0.5)*2, 3)*0.4);
y = floor(y*8.0)/8.0;
d *= lerp(1, lerp(0.25, 0.75, d), (1-y) * abs(i.uv.x-i.clr.y));

half4 lightCol = half4(lerp(0.529, 1, max(0, (light-0.5)*2)) * pow(1.0-i.clr.w, 0.2), lerp(0.365, 1, max(0, (light-0.5)*2)) * pow(1.0-i.clr.w, 0.2), lerp(0.184, 1, max(0, (light-0.5)*2)) * pow(1.0-i.clr.w, 0.2), 1);

lightCol = lerp(half4(d,d,d, 1), lightCol, min(1, light*2));
//lightCol = half4(1, 0, 0, 1);
lightCol.w = lerp(1, pow(clamp(i.uv.y*2, 0.3, 1), 2), max(0, i.clr.w-0.5)*2) * i.clr.x;
return lightCol;



}
ENDCG
				
				
				
			}
		} 
	}
}











