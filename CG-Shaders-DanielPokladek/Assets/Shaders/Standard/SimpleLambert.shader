Shader "Daniel/Standard/SimpleLambert"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf SimpleLambert
        #pragma target 3.5

        sampler2D _MainTex;

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
        
        // Custom lighting model used for the Lambert lighting.
        half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten)
        {
            half NdotL = dot(s.Normal, lightDir);                       // Using CG's built in 'dot' function,
                                                                        //  to calculate the dot product for the reflection
            half4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten * 1);
            c.a = s.Alpha;
            return c;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
