// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/WaterSplash" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _PalTex;

//uniform float _fogAmount;
//uniform float _waterPosition;

sampler2D _GrabTexture : register(s0);

uniform float _RAIN;

uniform float4 _spriteRect;
uniform float2 _screenSize;
uniform float _waterLevel;

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

float waterProximity = 1-clamp((i.scrPos.y - ((1-_waterLevel) - 0.14))*5, 0, 1);

//return half4(waterProximity,0,1-waterProximity, 1);

float2 textCoord = float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y)/_screenSize.y);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;

textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;


float dist = lerp(clamp(distance(i.uv.xy, half2(0.5, 0.5))*2, 0, 1), pow(abs(i.uv.x - 0.5) * 2, 0.7 - i.clr.w*0.4), i.clr.y);

 
half dstrtn = (sin((_RAIN + (tex2D(_NoiseTex, float2(textCoord.x*1.2, textCoord.y*1.2) ).x * 3) + 0/12.0) * 3.14 * 2)*0.5)+0.5;
float2 distortion = float2(lerp(-0.002, 0.002, dstrtn)*(1-dist), lerp(-0.002, 0.002, dstrtn)*(1-dist));
distortion.x = floor(distortion.x*_screenSize.x)/_screenSize.x;
distortion.y = floor(distortion.y*_screenSize.y)/_screenSize.y;

textCoord += distortion;

half h = 0.5+(sin((18.5 * _RAIN + tex2D(_NoiseTex, float2(textCoord.x*18.2, _RAIN * 2.4 + textCoord.y*12.2) ).x * 3) * 3.14)*0.5);

h *= tex2D(_NoiseTex, i.uv.xy - _RAIN*23*i.clr.x).x;


h = max(0, lerp(h, 1, i.clr.w * (1 - i.clr.z))-dist);

half4 texcol = tex2D(_LevelTex, textCoord + distortion);
float4 grabTexCol = tex2D(_GrabTexture, half2(i.scrPos.x, 1-i.scrPos.y) + distortion);
 
half dp = fmod((texcol.x * 255)-1, 30.0)/30.0;
if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0) dp = 1;
if(dp > 6.0/30.0){

if (grabTexCol.x == 0.0 && grabTexCol.y == 1.0/255.0 && grabTexCol.z == 0.0){
dp = 1;
grabTexCol = tex2D(_PalTex, float2(4.5/32.0, 7.5/8.0));
}
else if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0)
dp = 6.0/30.0;

}

h *= i.clr.w;



if(i.clr.z > 0.5) h -= 0.05;

if(h < lerp(0.05, 0.01, i.clr.w))
return float4(0, 0, 0, 0);




half4 rCol = lerp(tex2D(_PalTex, float2(5.5/32.0, 7.5/8.0)), tex2D(_PalTex, float2(4.5/32.0, 7.5/8.0)), dp);
rCol = lerp(rCol, tex2D(_PalTex, float2(0.5/32.0, 7.5/8.0)),  (1-i.clr.w)*0.5*dp*(1-waterProximity));

if(i.clr.z > 0.5)
rCol = lerp(rCol, half4(1,1,1,1), (0.3 + 0.2 * pow(0.5 + sin(_RAIN*25 + (textCoord.x - textCoord.y*2)/3)*0.5, 7) + 0.5 * dp)*(1-waterProximity));

if (dp >= 6.0/30.0 && (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0))
rCol = lerp(rCol, grabTexCol, lerp(1, 0.5, waterProximity));

return rCol;
}
ENDCG
				
				
				
			}
		} 
	}
}