Shader "Daniel/Effects/CellShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RampTex ("Ramp Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Toon
        #pragma target 3.5

        sampler2D _MainTex;
        sampler2D _RampTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
        }
        
        // Custom lighting model to be used with this Toon shader.
        fixed4 LightingToon (SurfaceOutput o, fixed3 lightDir, fixed atten)
        {
            half NdotL = dot(o.Normal, lightDir);
            NdotL = tex2D (_RampTex, fixed2(NdotL, 0.5));
            
            fixed4 c;
            c.rgb = o.Albedo * _LightColor0.rgb * NdotL * atten;
            c.a = o.Alpha;
            
            return c;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
