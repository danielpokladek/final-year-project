Shader "Custom/TerrainBlend"
{
    Properties
    {
		_MainTint("Diffuse Tint", Color)	= (1,1,1,1)

        _ColorA("Terrain Color A", Color)	= (1,1,1,1)
		_ColorB("Terrain Color B", Color)	= (1,1,1,1)
		_RTexture("Red Channel", 2D)		= ""{}
		_GTexture("Green Channel", 2D)		= ""{}
		_BTexture("Blue Channel", 2D)		= ""{}
		_ATexture("Alpha Channel", 2D)		= ""{}
		_BlendTex("Blend Texture", 2D)		= ""{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.5

        fixed4 _MainTint;		
		fixed4 _ColorA;
		fixed4 _ColorB;
		sampler2D _RTexture;		// Red Channel
		sampler2D _GTexture;		// Green Channel
		sampler2D _BTexture;		// Blue Channel
		sampler2D _ATexture;		// Alpha Channel
		sampler2D _BlendTex;		// Blend Texture
		

        struct Input
        {
            float2 uv_RTexture;
			float2 uv_GTexture;
			float2 uv_BTexture;
			float2 uv_ATexture;
			float2 uv_BlendTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
			// Get the pixel data from the blend texture
			// float 4 is used here because the texture
			// will return RGBA (or XYZW) variables
			float4 blendData = tex2D(_BlendTex, IN.uv_BlendTex);

			// Get the data from textures that will be used
			float4 rTexData = tex2D(_RTexture, IN.uv_RTexture);
			float4 gTexData = tex2D(_GTexture, IN.uv_GTexture);
			float4 bTexData = tex2D(_BTexture, IN.uv_BTexture);
			float4 aTexData = tex2D(_ATexture, IN.uv_ATexture);

			// No need to construct a new RGBA value and add all the different blended texture back together
			float4 finalColor;
			finalColor = lerp(rTexData, gTexData, blendData.g);
			finalColor = lerp(finalColor, bTexData, blendData.b);
			finalColor = lerp(finalColor, aTexData, blendData.a);
			finalColor.a = 1.0f;

			// Add on our terrain tinting colors
			float3 terrainLayers = lerp(_ColorA, _ColorB, blendData.r);
			float4 terrain = float4(terrainLayers.r, terrainLayers.g, terrainLayers.b, 1.0f);
			finalColor *= terrain;
			finalColor = saturate(finalColor);

			o.Albedo = finalColor.rgb * _MainTint.rgb;
			o.Alpha = finalColor.a;

            // Albedo comes from a texture tinted by color
            //fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            //o.Metallic = _Metallic;
            //o.Smoothness = _Glossiness;
            //o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
