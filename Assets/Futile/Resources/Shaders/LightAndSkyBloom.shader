// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance


Shader "Futile/LightAndSkyBloom" //Unlit Transparent Vertex Colored Additive 
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

float2 textCoord = i.scrPos;//float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y)/_screenSize.y);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;

textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;

//half4 texcol = tex2D(_LevelTex, textCoord);

half2 screenPos = half2(i.scrPos.x, 1-i.scrPos.y);

     half4 texcol = half4(0,0,0,1);
    float div = 1.0;
    float coef = 1.0;
    float coef2 = 1.0;
    float fI = 0;
    
    half  amount = pow(clamp(1- distance(half2(0.2,0.2), screenPos.xy), 0, 1), 0.5);
    amount *= i.clr.w;
    float _SkyBlurAmount = 0.0018;
    float _BlurAmount = 0.0018;// * amount;
    float horFac = _screenSize.y / _screenSize.x;
    
    half4 gCol = half4(0,0,0,0);
    half4 skyColor = tex2D(_PalTex, float2(0, 7));
    half red = 0;
    
    half4 addCol = half4(0,0,0,0);
    half4 midCol = tex2D(_GrabTexture, float2(screenPos.x, screenPos.y));
     
    for (int j = 0; j < 6; j++) {
    	fI++;
    	coef*=0.62;
    	
    	gCol = tex2D(_GrabTexture, float2(screenPos.x - fI * _SkyBlurAmount * horFac, screenPos.y - fI * _SkyBlurAmount));
	  if (gCol.x == skyColor.x && gCol.y == skyColor.y && gCol.z == skyColor.z){
	     	texcol += gCol * coef;
	     	div += coef;
	     }
	    red = tex2D(_LevelTex, float2(textCoord.x - fI * _BlurAmount * horFac, textCoord.y - fI * _BlurAmount)).x * 255;
	    if (red > 90 && red < 255)
    	addCol += half4(max(midCol.x, gCol.x), max(midCol.y, gCol.y), max(midCol.z, gCol.z), 1) * coef2;
    	
    	gCol = tex2D(_GrabTexture, float2(screenPos.x + fI * _SkyBlurAmount * horFac, screenPos.y - fI * _SkyBlurAmount));
	 if (gCol.x == skyColor.x && gCol.y == skyColor.y && gCol.z == skyColor.z){
    	texcol += gCol * coef;
    	div += coef;
    	}
    	 red = tex2D(_LevelTex, float2(textCoord.x + fI * _BlurAmount * horFac, textCoord.y - fI * _BlurAmount)).x * 255;
	    if (red > 90 && red < 255)
    	addCol += half4(max(midCol.x, gCol.x), max(midCol.y, gCol.y), max(midCol.z, gCol.z), 1) * coef2;
    	
    	gCol = tex2D(_GrabTexture, float2(screenPos.x + fI * _SkyBlurAmount * horFac, screenPos.y + fI * _SkyBlurAmount));
	 if (gCol.x == skyColor.x && gCol.y == skyColor.y && gCol.z == skyColor.z){
    	texcol += gCol * coef;
    	div += coef;
    	}
     red = tex2D(_LevelTex, float2(textCoord.x + fI * _BlurAmount * horFac, textCoord.y + fI * _BlurAmount)).x * 255;
	    if (red > 90 && red < 255)
    	addCol += half4(max(midCol.x, gCol.x), max(midCol.y, gCol.y), max(midCol.z, gCol.z), 1) * coef2;
    	
    	gCol = tex2D(_GrabTexture, float2(screenPos.x - fI * _SkyBlurAmount * horFac, screenPos.y + fI * _SkyBlurAmount));
	 if (gCol.x == skyColor.x && gCol.y == skyColor.y && gCol.z == skyColor.z){
    	texcol += gCol * coef;
    	div += coef;
	 }
	  red = tex2D(_LevelTex, float2(textCoord.x - fI * _BlurAmount * horFac, textCoord.y + fI * _BlurAmount)).x * 255;
	    if (red > 90 && red < 255)
    	addCol += half4(max(midCol.x, gCol.x), max(midCol.y, gCol.y), max(midCol.z, gCol.z), 1) * coef2;
    	
    	coef2 *= 0.9;
    }

 //if(tex2D(_LevelTex, float2(textCoord.x, textCoord.y - 0.1)).x * 255 < 90)
 //return half4(1, 0, 0, 1);
 
 half4 grabCol= tex2D(_GrabTexture, float2(screenPos.x, screenPos.y));
 grabCol += texcol*0.5;
 div *= 0.75;
 texcol = (grabCol + texcol) / div;

   grabCol.x = max(grabCol.x, texcol.x);
   grabCol.y = max(grabCol.y, texcol.y);
   grabCol.z = max(grabCol.z, texcol.z);
   
  
   
   addCol.x = max(0, addCol.x - lerp(0.7, 0.35, amount));
   addCol.y = max(0, addCol.y - lerp(0.7, 0.35, amount));
   addCol.z = max(0, addCol.z - lerp(0.7, 0.35, amount));

  // addCol = (grabCol + addCol) / div;
   
   addCol *= 0.5;
   
 //  grabCol += addCol * 0.5;
   
   if(addCol.x > grabCol.x)
   grabCol.x = lerp(grabCol.x, addCol.x, amount);
   
   if(addCol.y > grabCol.y)
   grabCol.y = lerp(grabCol.y, addCol.y, amount);
   
   if(addCol.z > grabCol.z)
   grabCol.z = lerp(grabCol.z, addCol.z, amount);
   
 
 
    return grabCol;
 

}
ENDCG
				
				
				
			}
		} 
	}
}