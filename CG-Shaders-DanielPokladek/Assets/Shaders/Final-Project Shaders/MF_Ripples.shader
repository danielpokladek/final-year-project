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
        #pragma target 3.0

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
            // Get and store the currente time value, from Unity's built in float4.
            float currTime = _Time.y;
            float calcTime = (1.0 - (frac(currTime*_RainSpeed)));
            
            float ripplesTex = tex2D(_PackedTexture, IN.uv_PackedTexture).r;
            float ripplesFade = abs(sin(calcTime));
            
            // First ripples
            float firstRipple = ripplesTex;                                                         // Assign the riiples texture.
            firstRipple = firstRipple - calcTime;                                                   // Calculate the alpha erosion of the texture.
            firstRipple = 1.0 - (smoothstep(0, 1, (distance(firstRipple, 0.05) / _EdgeWidth)));     // Calculate the edge of the ripples.
            firstRipple = firstRipple * ripplesFade;                                                // Apply fade to the ripples.
            
            // Second ripples - FIND HOW TO ADD OFFSET TO THE UV OF THE TEXTURE AS IT IS IN THE SHADER GRAPH
            float sr_calcTime = (1.0 - (frac((currTime + 1)*_RainSpeed)));
            float secondRipple = ripplesTex;
            secondRipple = secondRipple - sr_calcTime;
            secondRipple = 1.0 - (smoothstep(0, 1, (distance(secondRipple, 0.05) / _EdgeWidth)));
            secondRipple = secondRipple * ripplesFade;
            
            float lerpTime = clamp(0, 1, abs(sin((calcTime*_RainSpeed)*1)));
                        
            float finalEffect = lerp(firstRipple, secondRipple, lerpTime);
            
			// Apply shader to the material.
            o.Albedo = finalEffect;
			
			
			
			
			// o.Metallic = 0;
            //o.Smoothness = 0;
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
