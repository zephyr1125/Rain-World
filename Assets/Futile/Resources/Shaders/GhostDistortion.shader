// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/GhostDistortion" //Unlit Transparent Vertex Colored Additive 
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


sampler2D _GrabTexture : register(s0);
sampler2D _NoiseTex2;
uniform float2 _screenSize;
uniform float4 _spriteRect;
uniform float _RAIN;


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

     float dist = clamp(distance(i.uv.xy, half2(0.5, 0.5))*2, 0, 1);
     half2 dir = normalize(i.uv - half2(0.5, 0.5));
     
     half h = 0.0;
     for(int j = 0; j < 4; j++)
     h += tex2D(_NoiseTex2, half2(textCoord.x*0.25, textCoord.y*0.125 + _RAIN*0.2) + normalize(half2(0.5, 0.5) - i.uv) * 0.2 * j).x;

     h/=4.0;
     
     h = lerp(-1,1, h);
     
     half effect = pow((pow(sin(clamp((dist-0.5)*2, 0, 1)*3.14), 5)), 0.65);
     if(dist < 0.75)
     effect = max(effect, pow(clamp((dist-0.2)*1.8, 0, 1), 2));
     
     half2 grabPos = half2(i.scrPos.x, 1-i.scrPos.y) + dir *0.01 * h * clamp(sin(dist*3.142), 0, 1) * i.clr.w;
     grabPos += dir *0.04 * effect * sin(dist*20.0-_RAIN*13.1);
     grabPos.x = (floor(grabPos.x*_screenSize.x)+0.5)/_screenSize.x;
     grabPos.y = (floor(grabPos.y*_screenSize.y)+0.5)/_screenSize.y;
     
     
     half4 grabCol = tex2D(_GrabTexture, grabPos);
     half4 scr = half4(max(grabCol.x, -66.0/255.0), max(grabCol.y,131.0/255.0), max(grabCol.z,203.0/255.0), 1);
     grabCol = lerp(grabCol, scr, (1.0-dist)*0.5);
     
     return grabCol;

}
ENDCG
				
				
				
			}
		} 
	}
}