Shader "Dissertation/Research/Learning/AddingColours"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _AddColor("Add Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _BumpTex("Bump", 2D) = "bump" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpTex;

        struct Input
        {
            float2 uv_MainTex : TEXCOORD0;
            float2 uv_BumpTex : TEXCOORD1;
        };

        fixed4 _Color;
        fixed4 _AddColor;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
            o.Albedo += _AddColor;
            o.Normal = tex2D(_BumpTex, IN.uv_BumpTex);
        }
        ENDCG
    }
    FallBack "Diffuse"
}