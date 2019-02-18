Shader "Daniel/RainySurface/MF_Ripples"
{
    Properties
    {
        _PackedTex ("Packed Rain Texture", 2D) = "white" {}
        _NormalTex ("Normal Texture", 2D) = "white" {}
        _RainSpeed("Rain Speed", float) = 1.0
        _EdgeWidth("Ripple Edge Width", float) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
		#pragma enable_d3d11_debug_symbols 
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.5

        sampler2D _PackedTex;
        sampler2D _NormalTex;

        struct Input
        {
            float2 uv_PackedTex;
        };
        
        float _RainSpeed;
        float _EdgeWidth;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // X = rippleOneTime, Y = rippleTwoTime
            float2 rippleTimes;
        
            // Calculate the time to animate first set of ripples.
            // Next get the packed texture, and apply alpha erosion to it.
            // Calculate a fade effect for the ripples, and apply them.
            rippleTimes.x = 1.0 - (frac(_Time.y * _RainSpeed));
            
            float rippleOneTex  = tex2D(_PackedTex, IN.uv_PackedTex).r;                         // Use the '.r' at the end, to only get the red channel.
            float rippleOne     = rippleOneTex - rippleTimes.x;                                         // Use alpha erosion to create the effect of ripples expanding.
            float rippleOneWidth = 1.0 - (smoothstep(0, 1, (distance(rippleOne, 0.05) / _EdgeWidth)));  // Calculate the width of ripples.
            float rippleOneFade  = abs(sin((rippleTimes.x * _RainSpeed) * 0.5));
            
            float rippleOneFinal = rippleOneWidth * rippleOneFade;                                      // Combining the width calculation with the fade effect.
            
            
            // Calculate the time to animate second set of ripples.
            rippleTimes.y = (1.0 - (frac((_Time.y + .7) * _RainSpeed)));
            
            // Add UV offset to ripples, to make sure they are not on top of each other.
            float2 uv_ripplesTwoUV = IN.uv_PackedTex;
            uv_ripplesTwoUV.x = uv_ripplesTwoUV.x + 0.1;
            uv_ripplesTwoUV.y = uv_ripplesTwoUV.y + 0.1;
            
            // Next get the packed texture (with UV offset), and apply the alpha erosion to it.
            // Calculate the fade effect for the ripples and apply them.
            float rippleTwoTex     = tex2D(_PackedTex, uv_ripplesTwoUV).r;
            float rippleTwo         = rippleTwoTex - rippleTimes.y;
            float rippleTwoWidth    = 1.0 - (smoothstep(0, 1, (distance(rippleTwo, 0.05) / _EdgeWidth)));
            float rippleTwoFade     = abs(sin(((rippleTimes.y * _RainSpeed) * 0.5)));
            
            float rippleTwoFinal = rippleTwoWidth * rippleTwoFade;
            
            // Time used for the lerp function.
            //float lerpTime = (1.0 - frac(_Time.y * _RainSpeed));
            float lt = clamp(0, 1, abs(sin(((_Time.y * _RainSpeed)* 0.5))));
                        
            float finalEffect = lerp(rippleOneFinal, rippleTwoFinal, lt);
            
			// Apply shader to the material.
            o.Albedo = finalEffect;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
