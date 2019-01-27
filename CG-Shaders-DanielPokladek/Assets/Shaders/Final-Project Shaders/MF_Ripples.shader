﻿Shader "Daniel/RainySurface/MF_Ripples"
{
    Properties
    {
        _RainSpeed("Rain Speed", float) = 1.0
        _Color ("Color", Color) = (1,1,1,1)
        _PackedTexture ("Packed Rain Texture", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _PackedTexture;

        struct Input
        {
            float2 uv_PackedTexture;
            float _Time;                // Unity's built in Time function (time since level load)
        };
        
        float _RainSpeed;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Get the red channel of our packed texture.
            // Apply simple Alpha Erosion to simulate the "growing" of ripples
            float redChannel = tex2D(_PackedTexture, IN.uv_PackedTexture).r;
            redChannel = redChannel - (1.0 - frac(IN._Time*_RainSpeed));
            
            o.Albedo = redChannel;
//            
//            // Albedo comes from a texture tinted by color
//            fixed4 c = tex2D (_PackedTexture, IN.uv_PackedTexture) * _Color;
//            o.Albedo = c.rgb;
//            // Metallic and smoothness come from slider variables
//            o.Metallic = _Metallic;
//            o.Smoothness = _Glossiness;
//            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}