Shader "Dissertation/Research/Learning/Mixing Colours"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _SecTex("Secondary Texture", 2D) = "white" {}
        _Mix("Mix", Range(0, 1)) = 0.5
        _BumpTex("Bump", 2D) = "bump" {}
        _SecBump("Secondary Bump", 2D) = "bump" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _SecTex;
        sampler2D _BumpTex;
        sampler2D _SecBump;

        struct Input
        {
            float2 uv_MainTex : TEXCOORD0;
            float2 uv_SecTex  : TEXCOORD1;
            float2 uv_BumpTex : TEXCOORD2;
            float2 uv_SecBump : TEXCOORD3;
        };

        fixed4 _Color;
        float _Mix;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float3 mainTex = tex2D(_MainTex, IN.uv_MainTex).rgb;
            float3 secTex = tex2D(_SecTex, IN.uv_SecTex).rgb;
            o.Albedo = lerp(mainTex, secTex, _Mix);

            float3 mainBump = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex));
            float3 secBump = UnpackNormal(tex2D(_SecBump, IN.uv_SecBump));
            o.Normal = lerp(mainBump, secBump, _Mix);

            // Original implementation of just multiplying the textures
            /*o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
            o.Albedo *= tex2D(_SecTex, IN.uv_MainTex).rgb;
            o.Normal = tex2D(_BumpTex, IN.uv_BumpTex);*/
        }
        ENDCG
    }
    FallBack "Diffuse"
}