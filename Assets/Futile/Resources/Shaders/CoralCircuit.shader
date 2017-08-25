// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/CoralCircuit" //Unlit Transparent Vertex Colored Additive 
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
//uniform float _waterPosition;

//sampler2D _GrabTexture : register(s0);

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

if(distance(i.uv, half2(0.5, 0.5)) > 0.65)
return half4(0,0,0,0);

float myLeft = i.clr.x;
float myBottom = i.clr.y;



float myRight = myLeft + i.clr.z;
float myTop = myBottom + i.clr.w;



float2 sample = float2(lerp(myLeft, myRight, i.uv.x), lerp(myBottom, myTop, i.uv.y));

//if(sample.x > 1) sample.x --;
//if(sample.y > 1) sample.y --;

//return half4(tex2D(_MainTex, sample).xyz, 1);

if(tex2D(_MainTex, half2(lerp(myLeft, myRight, i.uv.x), lerp(myBottom, myTop, i.uv.y))).x > 0.5)
return half4(0,0,0,0);
half2 sampleCoord = textCoord * half2(_screenSize.x, _screenSize.y)/2.0;
sampleCoord.x = floor(sampleCoord.x)/_screenSize.x;
sampleCoord.y = floor(sampleCoord.y)/_screenSize.y;
float rand = frac(sin(dot(sampleCoord.x, 12.98232)*sampleCoord.y*0.23532+_RAIN-tex2D(_NoiseTex, half2(lerp(sampleCoord.y, lerp(0.265, 0.9455, sampleCoord.x), 0.5), _RAIN)).x) * 43758.5453);

//rand *= tex2D(_MainTex, half2(lerp(myLeft, myRight, i.uv.x), lerp(myBottom, myTop, i.uv.y))).x;
 
return half4(0.5+0.5*rand,0,0,1);//half4(0.5f+0.5*rand,clamp((rand-0.95)*10, 0, 1),0,1);

}
ENDCG
				
				
				
			}
		} 
	}
}