Shader "Daniel/RainySurface/MF_Ripples"
{
    Properties
    {
        _RainSpeed("Rain Speed", float) = 1.0
        _EdgeWidth("Ripple Edge Width", float) = 0.05
        _Color ("Color", Color) = (1,1,1,1)
        _PackedTexture ("Packed Rain Texture", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
		#pragma enable_d3d11_debug_symbols 
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.5

        sampler2D _PackedTexture;

        struct Input
        {
            float2 uv_PackedTexture;
        };
        
        float _RainSpeed;
        float _EdgeWidth;
        
        half _Glossiness;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Calculate the time to animate first set of ripples.
            // Next get the packed texture, and apply alpha erosion to it.
            // Calculate a fade effect for the ripples, and apply them.
            half rippleOneTime = 1.0 - (frac(_Time.y * _RainSpeed));
            
            float rippleOneTex  = tex2D(_PackedTexture, IN.uv_PackedTexture).r;                         // Use the '.r' at the end, to only get the red channel.
            float rippleOne     = rippleOneTex - rippleOneTime;                                         // Use alpha erosion to create the effect of ripples expanding.
            float rippleOneWidth = 1.0 - (smoothstep(0, 1, (distance(rippleOne, 0.05) / _EdgeWidth))); // Calculate the width of ripples.
            float rippleOneFade  = abs(sin((rippleOneTime * _RainSpeed) * 1.0));
            
            float rippleOneFinal = rippleOneWidth * rippleOneFade;                                      // Combining the width calculation with the fade effect.
            
            
            // Calculate the time to animate second set of ripples.
            half rippleTwoTime = (1.0 - (frac((_Time.y + 0.5) * _RainSpeed)));
            
            // Add UV offset to ripples, to make sure they are not on top of each other.
            float2 uv_ripplesTwoUV = IN.uv_PackedTexture;
            uv_ripplesTwoUV.x = uv_ripplesTwoUV.x + 0.1;
            uv_ripplesTwoUV.y = uv_ripplesTwoUV.y + 0.1;
            
            // Next get the packed texture (with UV offset), and apply the alpha erosion to it.
            // Calculate the fade effect for the ripples and apply them.
            float rippleTwoTex     = tex2D(_PackedTexture, uv_ripplesTwoUV).r;
            float rippleTwo         = rippleTwoTex - rippleTwoTime;
            float rippleTwoWidth    = 1.0 - (smoothstep(0, 1, (distance(rippleTwo, 0.05) / _EdgeWidth)));
            float rippleTwoFade     = abs(sin((rippleTwoTime * _RainSpeed) * 1.0));
            
            float rippleTwoFinal = rippleTwoWidth * rippleTwoFade;
            
            // Time used for the lerp function.
            float lerpTime = (1.0 - frac(_Time.y * 0.5));
            float lt = clamp(0, 1, (lerpTime * _RainSpeed)*0.5);
                        
            float finalEffect = lerp(rippleOneFinal, rippleTwoFinal, lt);
            
			// Apply shader to the material.
            o.Albedo = finalEffect;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
