// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/LevelMelt" //Unlit Transparent Vertex Colored Additive 
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

struct v2f {
    float4  pos : SV_POSITION;
    float2  uv : TEXCOORD0;
    float4 clr : COLOR;
};

float4 _MainTex_ST;

v2f vert (appdata_full v)
{
    v2f o;
    o.pos = UnityObjectToClipPos (v.vertex);
    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
    o.clr = v.color;
    return o;
}

half4 frag (v2f i) : COLOR
{
half4 setColor = half4(0.0, 0.0, 0.0, 1.0);
half2 screenPos = half2(lerp(_spriteRect.x, _spriteRect.z, i.uv.x), lerp(_spriteRect.y, _spriteRect.w, i.uv.y));
  
half4 texcol = tex2D(_MainTex, float2(i.uv.x, i.uv.y));

int red = texcol.x * 255;


 float effectCol = 0;
 
if (texcol.x == 1.0 && texcol.y == 1.0 && texcol.z == 1.0){
   setColor = half4(-1,-1,-1,-1);
   red = 31;
   }else{

   int green = texcol.y * 255;
   
   half notFloorDark = 1;
   if(green >= 16) {
   notFloorDark = 0;
   green -= 16;
   }
    

   
   

   
   
   red = fmod(red-1, 30.0);
   
   if (red >= 5){
		float4 grabTexCol = tex2D(_GrabTexture, float2(screenPos.x, 1-screenPos.y));
 		if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0){
     		 red = 5;
   		}
    }
   
    effectCol = tex2D(_NoiseTex, half2(i.uv.x, i.uv.y*0.5 + _RAIN*0.123));
    effectCol = 0.5 + 0.5 * sin(effectCol*3.14*8 + i.uv.y*36.231 + _RAIN*2.63 + (red/30.0)*8.12);
    effectCol *= 0.5 + 0.5 * sin(tex2D(_NoiseTex, half2((1.0-i.uv.x)*2, i.uv.y*0.5 + _RAIN*0.1862))*3.14*8 + i.uv.y*50.231 + _RAIN*4.75442 + (red/30.0)*8.12); 
    effectCol = 1- effectCol;
   

    effectCol = pow(effectCol, 30);

    texcol = tex2D(_MainTex, float2(i.uv.x, i.uv.y+lerp(-0.01, 0.02, effectCol)*i.clr.w));
    screenPos = half2(lerp(_spriteRect.x, _spriteRect.z, i.uv.x), lerp(_spriteRect.y, _spriteRect.w, i.uv.y+lerp(-0.01, 0.02, effectCol)*i.clr.w));
    screenPos.x = (floor(screenPos.x * 1366)+0.5)/1366;
    screenPos.y = (floor(screenPos.y * 768)+0.5)/768;
    int red = texcol.x * 255;
    red = fmod(red-1, 30.0);
    
     
    effectCol = 1-abs(effectCol-0.5)*2;
    effectCol = pow(max(0,effectCol-(1.0-i.clr.w)), lerp(10.0, 1.0, i.clr.w));

     
  int paletteColor = clamp(floor(red/30.0), 0, 2);//some distant objects want to get palette color 3, so we clamp it
    
    setColor =  tex2D(_PalTex, float2((red*notFloorDark)/32.0, (paletteColor + 0.5)/8.0));

  
   if (green > 0 && green < 3)
    effectCol = max(effectCol, texcol.z);
   
  
   
   setColor = lerp(setColor, tex2D(_PalTex, float2(1.5/32.0, 7.5/8.0)), clamp(red*(red < 10 ? lerp(notFloorDark, 1, 0.5) : 1)*_fogAmount/30.0, 0, 1));

}


   if (red >= 5){
		float4 grabTexCol = tex2D(_GrabTexture, float2(screenPos.x, 1-screenPos.y));
 		if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0){
     		 setColor = grabTexCol;
     		 red = 5;
     		 effectCol = 0;
   		}
    }
    
    if(setColor.x == -1){
   setColor = tex2D(_PalTex, float2(0.5/32.0, 7.5/8));
   effectCol = pow(1-i.uv.y,3) * 0.5 * i.clr.w;
   }
    
   effectCol = lerp(effectCol, 1, (red/30.0)*0.1*i.clr.w);
    
    if(effectCol < 0.75)
     setColor = lerp(setColor, lerp( tex2D(_PalTex, float2(31.5/32.0, 5.5/8.0)), tex2D(_PalTex, float2(30.5/32.0, 4.5/8.0)), red/30.0), effectCol/0.75);
    else
     setColor = lerp(lerp( tex2D(_PalTex, float2(31.5/32.0, 5.5/8.0)), tex2D(_PalTex, float2(30.5/32.0, 4.5/8.0)), red/30.0), half4(1,1,1,1), effectCol-0.75);


    return setColor;

}
ENDCG
				
				
				
			}
		} 
	}
}