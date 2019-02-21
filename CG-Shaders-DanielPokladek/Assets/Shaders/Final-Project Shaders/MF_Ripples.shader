Shader "Daniel/RainySurface/MF_Ripples"
{
    Properties
    {
        _PackedTex ("Packed Rain Texture", 2D) = "" {}
        _NormalTex ("Normal Texture", 2D) = "" {}
        _RainSpeed("Rain Speed", float) = 1.0
        _EdgeWidth("Ripple Edge Width", float) = 0.05
        _NormalMul("Normal Size", float) = 60
        _NormalCol("Normal Color", Color) = (0.5019608, 0.5019608, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM 
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 5.0

        sampler2D _PackedTex;
        sampler2D _NormalTex;

        struct Input
        {
            float2 uv_PackedTex;
            float2 uv_NormalTex;
        };
        
        float4 _NormalCol;
        float _RainSpeed;
        float _EdgeWidth;
        float _NormalMul;
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // X = rippleOneTime, Y = rippleTwoTime
            float2 rippleTimes;
            
            // --- BASE RIPPLES --- //
            // Calculate the time to animate first set of ripples.
            // Next get the packed texture, and apply alpha erosion to it.
            // Calculate a fade effect for the ripples, and apply them.
            rippleTimes.x = 1.0 - (frac(_Time.y * _RainSpeed));
            
            float3 rippleOneTex  = tex2D(_PackedTex, IN.uv_PackedTex).r;                         // Use the '.r' at the end, to only get the red channel.
            float3 rippleOne     = rippleOneTex - rippleTimes.x;                                         // Use alpha erosion to create the effect of ripples expanding.
            float3 rippleOneWidth = 1.0 - (smoothstep(0, 1, (distance(rippleOne, 0.05) / _EdgeWidth)));  // Calculate the width of ripples.
            float3 rippleOneFade  = abs(sin((rippleTimes.x * _RainSpeed) * 0.5));
            
            float3 rippleOneFinal = rippleOneWidth * rippleOneFade;                                      // Combining the width calculation with the fade effect.
            
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
            float lt = clamp(0, 1, abs(sin(((_Time.y * _RainSpeed)* 0.9))));
                        
            float finalEffect = lerp(rippleOneFinal, rippleTwoFinal, lt);
            
            // --- Normals --- //
            // Normals for the first set of ripples.
            float3 rippleOneNormal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));  // Unpack the normal texture, to make Unity read the rgb values properly.
                                                                                        //      without unpacking the texture, unity will read it as red texture and,
                                                                                        //      the lighting won't be applied properly.
                                                                                        
            rippleOneNormal = rippleOneNormal * rippleOneFinal;             // Make the normals appear/fade at the same time as the ripples. 
            rippleOneNormal = rippleOneNormal * _NormalMul;                 // The normals are quite small, so I need to enlarge them so the effect is visible.
            
            // Normals for the second set of ripples.
            float3 rippleTwoNormal = UnpackNormal(tex2D(_NormalTex, uv_ripplesTwoUV));
            rippleTwoNormal = rippleTwoNormal * rippleTwoFinal;
            rippleTwoNormal = rippleTwoNormal * _NormalMul;
            
            // Lerp the normals together, to achieve the seamless effect.
            // And add the purple colour to flat areas, so the flat areas can be read properly.
            // If I don't do that, the black areas will be read as super high and will create weird effects.
            float3 lNormal = lerp(rippleOneNormal, rippleTwoNormal, lt);
            float3 colorNormal = lNormal + _NormalCol;
            float3 finalNormal = lerp(colorNormal, _NormalCol, finalEffect);
            
			// Apply shader to the material.
            o.Albedo = finalEffect;
            o.Normal = finalNormal;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
