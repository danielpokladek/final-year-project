Shader "Dissertation/Ice/Components/SubsurfaceScattering"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _Ambient("Ambient", Color) = (1,1,1,1)
        _LocalThickness("Thickness Map", 2D) = "white" {}
        _Distortion ("Distortion", float) = 1
        _Power("Power", float) = 1
        _Scale("Scale", float) = 1
        _Attenuation("Attenuation", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf StandardTranslucent fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float4 _Ambient;
        sampler2D _LocalThickness;
        float _Distortion;
        float _Power;
        float _Scale;
        float _Attenuation;
        float thickness;

        #include "UnityPBSLighting.cginc"
        inline fixed4 LightingStandardTranslucent(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
        {
            fixed4 pbr = LightingStandard(s, viewDir, gi);

            float3 L = gi.light.dir;
            float3 V = viewDir;
            float3 N = s.Normal;

            float3 H = L + N * _Distortion;
            float VdotH = pow(saturate(dot(V, -H)), _Power) * _Scale;
            float3 I = _Attenuation * (VdotH + _Ambient) * thickness;

            pbr.rgb = pbr.rgb + gi.light.color * I;
            return pbr;
        }

        void LightingStandardTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);
        }


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            thickness = tex2D(_LocalThickness, IN.uv_MainTex).r;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
