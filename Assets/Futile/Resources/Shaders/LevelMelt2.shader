// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Futile/LevelMelt2" //Unlit Transparent Vertex Colored Additive 
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
sampler2D _LevelTex;
sampler2D _NoiseTex;
sampler2D _PalTex;
//uniform float _fogAmount;
//uniform float _waterPosition;

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

half2 grabPos = half2(i.scrPos.x, 1-i.scrPos.y);

 float effectCol = tex2D(_NoiseTex, half2(textCoord.x, textCoord.y*0.05 + _RAIN*0.0123));
    effectCol = 0.5 + 0.5 * sin(effectCol*3.14*8 + textCoord.y*36.231 + _RAIN*0.63 *8.12);
  
   // effectCol = 1 - effectCol;
    
    grabPos.y += lerp(-lerp(0.01, 0.001, i.clr.x), lerp(0.01, 0.001, i.clr.x), effectCol)*i.clr.w;
    grabPos.x = (floor(grabPos.x * 1366)+0.5)/1366.0;
    grabPos.y = (floor(grabPos.y * 768)+0.5)/768.0;

half4 grabCol = tex2D(_GrabTexture, float2(grabPos.x, grabPos.y));



  for (int j = 1; j < 4; j++) {
   grabPos.y -= lerp(-lerp(0.05, 0.01, i.clr.x), lerp(0.05, 0.01, i.clr.x), effectCol*j)*i.clr.w*(j % 2 == 1 ? -1 : 1);
   grabPos.x = (floor(grabPos.x * 1366)+0.5)/1366.0;
   grabPos.y = (floor(grabPos.y * 768)+0.5)/768.0;

   grabCol += lerp(grabCol, tex2D(_GrabTexture, float2(grabPos.x, grabPos.y)), 0.5);
   }
   grabCol /= 5;

half4 effCol = half4(0.529, 0.365, 0.184, 1);//tex2D(_PalTex, float2(31.5/32.0, 5.5/8.0)); //don't want this to be dynamic, it should always be the gold color

float av = (abs(effCol.x-grabCol.x) + abs(effCol.y-grabCol.y) + abs(effCol.z-grabCol.z))/3.0;

grabCol = lerp(grabCol, lerp(half4(0,0,0,1), effCol, pow(1.0-av, 10)*2.0), max(0, i.clr.w-0.65)/0.35);

return grabCol * lerp(1, 3 + 1.0-av, ((grabCol.x+grabCol.y+grabCol.z)/3.0)*pow(min((i.clr.w-0.5)*3.5, 1), 3));


}
ENDCG
				
				
				
			}
		} 
	}
}




