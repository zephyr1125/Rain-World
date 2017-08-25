// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/Projection" //Unlit Transparent Vertex Colored Additive 
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
uniform float4 _lightDirAndPixelSize;


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

int red = fmod((texcol.x * 255)-1, 30.0);
if(red < 1) return half4(0,0,0,0);
half depth = red/30.0;
bool maskOut = false;

half2 grabPos = float2(i.scrPos.x + -_lightDirAndPixelSize.x*_lightDirAndPixelSize.z*(red-5), 1-i.scrPos.y + -_lightDirAndPixelSize.y*_lightDirAndPixelSize.w*(red-5));
grabPos = ((grabPos-half2(0.5, 0.3))*(1 + (red-5.0)/460.0))+half2(0.5, 0.3);




half4 grabColor = tex2D(_GrabTexture, half2(i.scrPos.x, 1-i.scrPos.y));
if((grabColor.x <= 1.0/255.0 && grabColor.y == 0.0 && grabColor.z == 0.0) || red < 5){
	//baked BKG shadows
	if(texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0) maskOut = true;
	if(texcol.x * 255 <= 90) maskOut = true;

		//Sprites shading bkg
		if(red > 5){
		grabColor = tex2D(_GrabTexture, grabPos);
		if(grabColor.x > 1.0/255.0 || grabColor.y != 0.0 || grabColor.z != 0.0)
		maskOut = true;
	}
	

    
}else{

	half2 sz = _lightDirAndPixelSize.zw;//half2(1/(_screenSize.x/(1.0/_lightDirAndPixelSize.z)), 1/(_screenSize.y/(1.0/_lightDirAndPixelSize.w)));

	//Shadows from bkg on sprites
	textCoord.x -= _lightDirAndPixelSize.x*sz.x*(red-5);
	textCoord.y += _lightDirAndPixelSize.y*sz.y*(red-5);
	texcol = tex2D(_LevelTex, textCoord);
	if(texcol.x != 1.0 || texcol.y != 1.0 || texcol.z != 1.0) {
	int compRed = fmod((texcol.x * 255)-1, 30.0);
	if(compRed < 6)
		maskOut = true;
	red = 5;
	}
}

if(maskOut) return half4(0,0,0,0);

	half2 displace = -_lightDirAndPixelSize.xy;
	displace.x *= _lightDirAndPixelSize.z * (red-5);
	displace.y *= _lightDirAndPixelSize.w * (red-5);
	displace.x *= (1.0/_lightDirAndPixelSize.z) / lerp(1.0, 1000.0, i.clr.x);
	displace.y *= (1.0/_lightDirAndPixelSize.w) / lerp(1.0, 1000.0, i.clr.y);
	
	half4 clr = tex2D(_MainTex, i.uv.xy + half2(displace.x, -displace.y));
	clr.w *= i.clr.w;
return clr;

}
ENDCG
				
				
			}
		} 
	}
}