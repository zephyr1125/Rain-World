// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance


Shader "Futile/Bloom" //Unlit Transparent Vertex Colored Additive 
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
//sampler2D _PalTex;
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

    half4 getCol = half4(0,0,0,1);
    half4 texcol = half4(0,0,0,1);
    half4 goalColor = half4(1,0,0,1);
    float div = 0.0;
    float coef=1.0;
    float fI = 0;
    float _BlurAmount = 0.0012;// * i.clr.w;
    float horFac = _screenSize.y / _screenSize.x;
    
  //  half red = 0;
  half add = 0;
    
    for (int j = 0; j < 4; j++) {
    	fI++;
    	coef*=0.92;
    	
    	texcol = tex2D(_GrabTexture, float2(screenPos.x, screenPos.y - fI * _BlurAmount)) * coef;
    	//add = 1.0-max(max(abs(texcol.x-goalColor.x), abs(texcol.y-goalColor.y)), abs(texcol.z-goalColor.z));
    	//getCol += texcol*clamp(pow(add, 2)*10, 0, 1);
    	getCol += texcol;
    	
    	texcol = tex2D(_GrabTexture, float2(screenPos.x - fI * _BlurAmount * horFac, screenPos.y)) * coef;
      	//add = 1.0-max(max(abs(texcol.x-goalColor.x), abs(texcol.y-goalColor.y)), abs(texcol.z-goalColor.z));
    	//getCol += texcol*clamp(pow(add, 2)*10, 0, 1);
    	getCol += texcol;
    	
    	texcol = tex2D(_GrabTexture, float2(screenPos.x + fI * _BlurAmount * horFac, screenPos.y)) * coef;
    	//add = 1.0-max(max(abs(texcol.x-goalColor.x), abs(texcol.y-goalColor.y)), abs(texcol.z-goalColor.z));
    	//getCol += texcol*clamp(pow(add, 2)*10, 0, 1);
    	getCol += texcol;
    	
    	texcol = tex2D(_GrabTexture, float2(screenPos.x, screenPos.y + fI * _BlurAmount)) * coef;
    	//add = 1.0-max(max(abs(texcol.x-goalColor.x), abs(texcol.y-goalColor.y)), abs(texcol.z-goalColor.z));
    	//getCol += texcol*clamp(pow(add, 2)*10, 0, 1);
    	getCol += texcol;
    		
    	div += 4*coef;
    }
    
    
     getCol /= div;
     

     
    
     getCol *= i.clr.w * lerp(1, 0.5, distance(i.uv, half2(0.5, 0.5)) *2.0);

     half4 grabCol= tex2D(_GrabTexture, float2(screenPos.x, screenPos.y));
     
     grabCol.x = max(grabCol.x, getCol.x);
     grabCol.y = max(grabCol.y, getCol.y);
     grabCol.z = max(grabCol.z, getCol.z);
       
 
     getCol.x = pow(getCol.x, 1.5);
     getCol.y = pow(getCol.y, 1.5);
     getCol.z = pow(getCol.z, 1.5);
      
     return grabCol + getCol;

}
ENDCG
				
				
				
			}
		} 
	}
}