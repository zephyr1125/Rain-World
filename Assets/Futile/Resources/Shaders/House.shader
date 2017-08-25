// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

	
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

//from http://forum.unity3d.com/threads/68402-Making-a-2D-game-for-iPhone-iPad-and-need-better-performance

Shader "Futile/House" //Unlit Transparent Vertex Colored Additive 
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
//sampler2D _NoiseTex;
sampler2D _NoiseTex2;
//sampler2D _CloudsTex;
sampler2D _PalTex;
sampler2D _ApartmentsTex;
sampler2D _CityPalette;
//uniform float _fogAmount;
uniform half4 _AboveCloudsAtmosphereColor;
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

float3 random2f(in float2 coord){
return tex2D(_NoiseTex2, coord/256.0).xyz * tex2D(_NoiseTex2, coord/366.0).xyz;
}
//
//
//float voronoi( in half2 x )
//{
//    int2 cell = floor( x );
//    half2 inCellPos = frac( x );
//
//    float res = 8.0;
//    for( int j=-1; j<=1; j++ )
//    for( int i=-1; i<=1; i++ )
//    {
//        int2 offst = int2( i, j );
//        half3 cellData = random2f(cell + offst);
//        half2 r = half2( offst ) - inCellPos + cellData.xy;//random2f( p + b );
//        float d = dot( r, r );
//		d *= lerp(0.1, 1, cellData.z);
//        res = min( res, d );
//    }
//    return sqrt( res );
//}




half4 frag (v2f i) : COLOR
{

float2 textCoord = float2(floor(i.scrPos.x*_screenSize.x)/_screenSize.x, floor(i.scrPos.y*_screenSize.y)/_screenSize.y);

textCoord.x -= _spriteRect.x;
textCoord.y -= _spriteRect.y;

textCoord.x /= _spriteRect.z - _spriteRect.x;
textCoord.y /= _spriteRect.w - _spriteRect.y;

half4 lvlCol = tex2D(_LevelTex, textCoord);
if(lvlCol.x != 1 && lvlCol.y != 1 && lvlCol.z != 1) return half4(0,0,0,0);

half4 grabTexCol = tex2D(_GrabTexture, half2(i.scrPos.x, 1-i.scrPos.y));
if (grabTexCol.x > 1.0/255.0 || grabTexCol.y != 0.0 || grabTexCol.z != 0.0) return half4(0,0,0,0);

half2 div = half2(0.01, 0.025)*(1.0/i.clr.z)*half2(i.clr.x*4000.0, i.clr.y*1500.0);

half2 grabCoord = i.uv;
half2 cell = half2(floor(grabCoord.x*div.x)/div.x, floor(grabCoord.y*div.y)/div.y);

grabCoord.y += lerp(-0.7, 0.7, random2f(half2(cell.x*div.x, 0.5)).x)/div.x;
grabCoord.x += lerp(-0.1, 0.1, random2f(cell*half2(102.21, 91.3232)).x)/div.y;

cell = half2(floor(grabCoord.x*div.x)/div.x, floor(grabCoord.y*div.y)/div.y);


half4 texCellColor = tex2D(_MainTex, cell);


half d = floor((1.0-texCellColor.x)*4.0)/4.0;




div = half2(0.01, 0.025)*(1.0/i.clr.z)*half2(i.clr.x*4000.0, i.clr.y*1500.0)*lerp(0.75, 3, d);

grabCoord = i.uv;

cell = half2(floor(grabCoord.x*div.x)/div.x, floor(grabCoord.y*div.y)/div.y);

grabCoord.y += lerp(-0.7, 0.7, random2f(half2(cell.x*div.x, 0.5)).x)/div.x;
grabCoord.x += lerp(-0.1, 0.1, random2f(cell*half2(102.21, 91.3232)).x)/div.y;

cell = half2(floor(grabCoord.x*div.x)/div.x, floor(grabCoord.y*div.y)/div.y);
texCellColor = tex2D(_MainTex, cell);



if(texCellColor.x < 0.1) return half4(0,0,0,0);

half3 cellColor = random2f(cell*half2(754.21, 1.3232));

//return half4(cellColor, 1);

grabCoord = half2(floor(cellColor.x*5.0)/5.0, floor(cellColor.y*5.0)/5.0) + (grabCoord - cell)*div/5.0;

//half blck = tex2D(_ApartmentsTex, floor((grabCoord)*3.0)/3.0 + cellColor.z).x;


//grabCoord.x = floor(grabCoord.x*50*20+0.5)/(50*20);
//grabCoord.y = floor(grabCoord.y*20*20+0.5)/(20*20);

half palette = floor(random2f(cell*half2(lerp(44.0, 60.0, cellColor.z), 0.1232)).z*32.0)/32.0;

half4 texCol = tex2D(_CityPalette, half2(1.0-tex2D(_ApartmentsTex, grabCoord).x, palette));// * half4(random2f(cell*half2(5123.945234, 1.0)), 1);// half4(cellColor.xyz, 1);// tex2D(_MainTex, grabCoord);

//texCol.xyz *= clamp(blck*3, 0.5, 1);

float light = ((1.0-texCellColor.z) * cellColor.z * 2.0 + cellColor.y) / 3;

if(light < 0.2) texCol.xyz *= 0.6;


//return half4(shadow, shadow, shadow, 1);

texCol = lerp(texCol, _AboveCloudsAtmosphereColor, pow(clamp((1.0/i.clr.z) / 15.0, 0, 1), 0.6)*0.9);

return texCol;

}



ENDCG
				
				
				
			}
		} 
	}
}