Shader "Dissertation/Ice/IceSurfShader"
{
    Properties
    {
        [Header(Base)]
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        [Normal]_Normal("Normal Map", 2D) = "bump" {}
        _Emission("Emission", 2D) = "white" {}
        _Metallic("Metallic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0.5

        [Header(Subsurface Scattering)]
        _Ambient("Ambient Colour", color) = (1,1,1,1)
        _LocalThickness("Thickness Map", 2D) = "white" {}
        _Distortion("Distortion Amount", float) = 1
        _Power("Power", float) = 1
        _Scale("Scale", float) = 1
        _Attenuation("Attenuation", float) = 1
        
        [Header(Distortion)]
        [Normal]_DistortTex("Distortion Texture", 2D) = "bump" {}
        _DistortAmount("Distortrion Amount", Range(0, 50)) = 25
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        Cull Back
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 200

        GrabPass
        {
            "_GrabTexture"
        }

        CGPROGRAM
        #pragma surface surf StandardTranslucent fullforwardshadows vertex:vert
        #pragma target 3.5

        sampler2D _GrabTexture;

        sampler2D _MainTex;
        sampler2D _Normal;
        sampler2D _Emission;

        sampler2D _DistortTex;
        float4 _DistortTex_ST;
        float _DistortAmount;
        
        float _Metallic;
        float _Smoothness;

        float4 _Ambient;
        sampler2D _LocalThickness;
        float _Distortion;
        float _Power;
        float _Scale;
        float _Attenuation;
        float thickness;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Normal;

            float4 grabUV;
            float2 distortUV;
            float4 color;
        };

        #include "UnityPBSLighting.cginc"
        inline fixed4 LightingStandardTranslucent(SurfaceOutputStandard s,
            fixed3 viewDir, UnityGI gi)
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

        void LightingStandardTranslucent_GI(SurfaceOutputStandard s,
            UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);
        }

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float4 pos = UnityObjectToClipPos(v.vertex);

            o.grabUV = ComputeGrabScreenPos(pos);
            o.distortUV = TRANSFORM_TEX(v.texcoord, _DistortTex);
            
            o.color = v.color;
        }

        float4 alphaBlend(float4 top, float4 bottom)
        {
            float3 color = (top.rgb * top.a) + (bottom.rgb * (1 - top.a));
            float alpha = top.a + bottom.a * (1 - top.a);

            return float4(color, alpha);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 distort = UnpackNormal(tex2D(_DistortTex, IN.distortUV)).xy;
            distort *= _DistortAmount * IN.color.a;
            IN.grabUV.xy += distort * IN.grabUV.z;

            float4 grab = tex2Dproj(_GrabTexture, IN.grabUV);
            float4 tex = tex2D(_MainTex, IN.uv_MainTex);
            float4 colour = tex - grab;

            o.Albedo = colour;
            o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Normal));
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Alpha = colour.a;

            thickness = tex2D(_LocalThickness, IN.uv_MainTex).r;
        }
        ENDCG
    }
    FallBack "Transparent/VertexLit"
}
