Shader "Dissertation/Ice/Components/Refraction"
{
    Properties
    {
        [Normal]_DistortTex("Distortion Texture", 2D) = "bump" {}
        _DistortAmount("Distortion Amount", Range(0, 50)) = 25
    }
        SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        Cull Back
        ZWrite Off
        LOD 100

        GrabPass
        {
            // Grab Pass grabs what is behind the object and packs it into a texture,
            // which can later be accessed via the parameter below.
            "_GrabTexture"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                // float4 used instead of float2,
                //  as unlike tex2D, tex2Dproj returns a float4.
                float4 screenUV : TEXCOORD1;
                float2 distortUV : TEXCOORD2;
                float4 color : COLOR;
            };

            sampler2D _GrabTexture;
            sampler2D _DistortTex;
            float4 _DistortTex_ST;
            float _DistortAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.distortUV = TRANSFORM_TEX(v.uv, _DistortTex);
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                o.color = v.color;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 distort = UnpackNormal(tex2D(_DistortTex, i.distortUV)).xy;
                distort *= _DistortAmount * i.color.a;
                i.screenUV.xy += distort * i.screenUV.z;

                float4 grab = tex2Dproj(_GrabTexture, i.screenUV);

                return grab;
            }
            ENDCG
        }
    }
}
