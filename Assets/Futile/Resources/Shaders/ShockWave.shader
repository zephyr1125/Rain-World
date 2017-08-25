// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/ShockWave" //Unlit Transparent Vertex Colored Additive 
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

     float dist = clamp(1-distance(i.uv.xy, half2(0.5, 0.5))*2, 0, 1);
  
     
     float diff = pow(abs(dist - (1.0-i.clr.z)), i.clr.y) * dist * (1.0-i.clr.z); 

     half2 dir = normalize(i.uv.xy - half2(0.5, 0.5)); 
     
 
     
     half2 grabPos = half2(i.scrPos.x, 1-i.scrPos.y) - (dir * i.clr.x * i.clr.y * diff);
     grabPos.x = (floor(grabPos.x*_screenSize.x)+0.5)/_screenSize.x;
     grabPos.y = (floor(grabPos.y*_screenSize.y)+0.5)/_screenSize.y;

 // half4 texcol = tex2D(_LevelTex, textCoord);

return tex2D(_GrabTexture, grabPos);//half4(dist, dist, 0, 1);
}
ENDCG
				
				
				
			}
		} 
	}
}