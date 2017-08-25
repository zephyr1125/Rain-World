// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/BlackGoo" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _PalTex;
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

//if(distance(i.uv, half2(0.5, 0.5)) > 0.5)
//return half4(0,0,0,0);

float2 textCoord = float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y)/_screenSize.y);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;

textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;

half4 levCol = tex2D(_LevelTex, textCoord);



half terrainDpth = ((int)(levCol.x * 255) % 30)/30.0;
if(levCol.x == 1 && levCol.y == 1 && levCol.z == 1)
terrainDpth = 1;

if(terrainDpth > 6.0/30.0){
float4 grabTexCol = tex2D(_GrabTexture, half2(i.scrPos.x, 1-i.scrPos.y));
if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0)
return float4(0,0,0,0);
}

terrainDpth -= 0.18;
terrainDpth = max(terrainDpth, 0) / 0.82;

half4 textCol = tex2D(_MainTex, i.uv + normalize(i.uv-half2(0.5, 0.5)) * terrainDpth * 0.12);

half4 setCol = tex2D(_PalTex, half2(2.5/32.0, 7.5/8.0));
setCol = lerp(setCol,  half4(0.5,0.5,0.7,1)*tex2D(_PalTex, half2(30.5/32.0, 7.5/8.0)).x, pow(terrainDpth, 0.45)*0.25);//tex2D(_PalTex, half2(1.5/32.0, 7.5/8.0)), max(0,terrainDpth-0.2)*1.25* tex2D(_PalTex, half2(9.5/32.0, 7.5/8.0)).x);

half alpha = 1-textCol.x;


alpha *= 0.4 + 0.6 * tex2D(_NoiseTex, half2(textCoord.x*8, textCoord.y*4)).x;



if(alpha > 0.5)
alpha = pow(alpha, 0.7);

//alpha = tex2D(_NoiseTex, half2(textCoord.x*12 + 0.1*terrainDpth, textCoord.y*6 - 0.15*terrainDpth)).x * pow(clamp(1-distance(i.uv, half2(0.5, 0.5))*2, 0, 1), 0.5);
alpha = max(0, alpha - terrainDpth * 0.2);

if(alpha < 0.3)
return half4(0,0,0,0);
else if(alpha > 0.6)
return half4(setCol.xyz, 1);
else
return half4(setCol.xyz, 0.5);

}
ENDCG
				
				
			}
		} 
	}
}















