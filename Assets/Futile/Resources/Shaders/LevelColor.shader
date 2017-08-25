// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/LevelColor" //Unlit Transparent Vertex Colored Additive 
{
	Properties 
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		
	//	_PalTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		
	//	_NoiseTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		
		//    _RAIN ("Rain", Range (0,1.0)) = 0.5
		//_Color ("Main Color", Color) = (1,0,0,1.5)
		//_BlurAmount ("Blur Amount", Range(0,02)) = 0.0005
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
sampler2D _PalTex;
sampler2D _NoiseTex;
sampler2D _GrabTexture : register(s0);

//float _BlurAmount;


uniform float _palette;
uniform float _RAIN;
uniform float _light = 0;
uniform float4 _spriteRect;

uniform float4 _lightDirAndPixelSize;
uniform float _fogAmount;
uniform float _waterLevel;
uniform float _Grime;
uniform float _SwarmRoom;
uniform float _WetTerrain;
uniform float _cloudsSpeed;

struct v2f {
    float4  pos : SV_POSITION;
    float2  uv : TEXCOORD0;
};

float4 _MainTex_ST;

v2f vert (appdata_base v)
{
    v2f o;
    o.pos = UnityObjectToClipPos (v.vertex);
    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
    return o;
}

half4 frag (v2f i) : COLOR
{

//float rand = frac(sin(dot(i.uv.x, 12.98232)+_RAIN-i.uv.y) * 43758.5453);
half4 setColor = half4(0.0, 0.0, 0.0, 1.0);
bool checkMaskOut = false;

float ugh = fmod(fmod(   tex2D(_MainTex, float2(i.uv.x, i.uv.y)).x*255   , 90)-1, 30)/300.0;
float displace = tex2D(_NoiseTex, float2((i.uv.x * 1.5) - ugh + (_RAIN*0.01), (i.uv.y*0.25) - ugh + _RAIN * 0.05)   ).x;
displace = clamp((sin((displace + i.uv.x + i.uv.y + _RAIN*0.1) * 3 * 3.14)-0.95)*20, 0, 1);


 
  half2 screenPos = half2(lerp(_spriteRect.x, _spriteRect.z, i.uv.x), lerp(_spriteRect.y, _spriteRect.w, i.uv.y));
  
  if (_WetTerrain < 0.5 || 1-screenPos.y > _waterLevel) displace = 0;

half4 texcol = tex2D(_MainTex, float2(i.uv.x, i.uv.y+displace*0.001));



//if(texcol.y * 255 > 7 && texcol.y * 255 < 11) return float4(0,0,1,1);
   
   if (texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0){
   setColor = tex2D(_PalTex, float2(0.5/32.0, 7.5/8));
 //  setColor = half4(0,0,0,0);
   checkMaskOut = true;
   }else{
  
   
   int red = texcol.x * 255;
   int green = texcol.y * 255;
   
   int effectCol = 0;
   half notFloorDark = 1;
   if(green >= 16) {
   notFloorDark = 0;
   green -= 16;
   }
   if(green >= 8){
   effectCol = 100;
 //  green = 8;
   green -= 8;
 //  return half4(0,0,0,0);
   }else
   effectCol = green;

   
   half shadow = tex2D(_NoiseTex, float2((i.uv.x*0.5) + (_RAIN*0.1*_cloudsSpeed) - (0.003*fmod(red, 30.0)), 1-(i.uv.y*0.5) + (_RAIN*0.2*_cloudsSpeed) - (0.003*fmod(red, 30.0)))).x;
 
   shadow = 0.5 + sin(fmod(shadow+(_RAIN*0.1*_cloudsSpeed)-i.uv.y, 1)*3.14*2)*0.5;
   shadow = clamp(((shadow - 0.5)*6)+0.5-(_light*4), 0,1);

   if (red > 90)
         red -= 90;
   else
         shadow = 1.0;
   
   
 	
   
   int paletteColor = clamp(floor((red-1)/30.0), 0, 2);//some distant objects want to get palette color 3, so we clamp it
   
   
   red = fmod(red-1, 30.0);
  
    
   if (shadow != 1 && red >= 5) {
   half2 grabPos = float2(screenPos.x + -_lightDirAndPixelSize.x*_lightDirAndPixelSize.z*(red-5), 1-screenPos.y + -_lightDirAndPixelSize.y*_lightDirAndPixelSize.w*(red-5));
   grabPos = ((grabPos-half2(0.5, 0.3))*(1 + (red-5.0)/460.0))+half2(0.5, 0.3);
   	float4 grabTexCol2 = tex2D(_GrabTexture, grabPos);
 		if (grabTexCol2.x != 0.0 || grabTexCol2.y != 0.0 || grabTexCol2.z != 0.0){
     		 shadow = 1;
  		 }
   }
   
    setColor = lerp(tex2D(_PalTex, float2((red*notFloorDark)/32.0, (paletteColor + 3 + 0.5)/8.0)), tex2D(_PalTex, float2((red*notFloorDark)/32.0, (paletteColor + 0.5)/8.0)), shadow);


	half rbcol = (sin((_RAIN + (tex2D(_NoiseTex, float2(i.uv.x*2, i.uv.y*2) ).x * 4) + red/12.0) * 3.14 * 2)*0.5)+0.5;
  	setColor = lerp(setColor, tex2D(_PalTex, float2((5.5 + rbcol*25)/32.0, 6.5 / 8.0) ), (green >= 4 ? 0.2 : 0.0) * _Grime);
   

  
    
   if (effectCol == 100){
 half4 decalCol = tex2D(_MainTex, float2((255.5-texcol.z*255.0)/1400.0, 799.5/800.0));
 if(paletteColor == 2) decalCol = lerp(decalCol, half4(1, 1, 1, 1), 0.2 - shadow*0.1);
 decalCol = lerp(decalCol, tex2D(_PalTex, float2(1.5/32.0, 7.5/8.0)), red/60.0);
 setColor = lerp(lerp(setColor, decalCol, 0.7), setColor*decalCol*1.5,  lerp(0.9, 0.3+0.4*shadow, clamp((red-3.5)*0.3, 0, 1) ) );
}
   else if (green > 0 && green < 3){
    setColor = lerp(setColor, lerp(lerp(tex2D(_PalTex, float2(30.5/32.0, (5.5-(effectCol-1)*2)/8.0)), tex2D(_PalTex, float2(31.5/32.0, (5.5-(effectCol-1)*2)/8.0)), shadow), lerp(tex2D(_PalTex, float2(30.5/32.0, (4.5-(effectCol-1)*2)/8.0)), tex2D(_PalTex, float2(31.5/32.0, (4.5-(effectCol-1)*2)/8.0)), shadow), red/30.0), texcol.z);
  }else if (green == 3){
  setColor = lerp(setColor, half4(1, 1, 1, 1), texcol.z*_SwarmRoom);
    }
   
 setColor = lerp(setColor, tex2D(_PalTex, float2(1.5/32.0, 7.5/8.0)), clamp(red*(red < 10 ? lerp(notFloorDark, 1, 0.5) : 1)*_fogAmount/30.0, 0, 1));

   if (red >= 5){
	checkMaskOut = true; 	
    }
    

    
  }
  
if (checkMaskOut){
 
		float4 grabTexCol = tex2D(_GrabTexture, float2(screenPos.x, 1-screenPos.y));
 		if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0){
     		 setColor.w = 0;
   		}
}


    return setColor;

}
ENDCG
				
				
				
			}
		} 
	}
}