// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

// Based on Roystan's cartoon water shader

Shader "Dissertation/Water/WaterToonShader"
{
    Properties
    {
        [Header(Surface Noise)]
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777

        [Header(Surface Settings)]
        _ShallowColour("Shallow Colour", Color) = (0.325, 0.807, 0.971, 0.725)
        _DeepColour("Deep Colour", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Maximum Depth Distance", Float) = 1

        [Header(Foam Settings)]
        _FoamColour("Foam Colour", Color) = (1,1,1,1)
        _FoamDistanceMax("Maximum Foam Distance", Float) = 0.4
        _FoamDistanceMin("Minimum Foam Distance", Float) = 0.04

        [Header(Animation Settings)]
        _NoiseTex("Wave Noise Texture", 2D) = "white" {}
        _WaveAmp("Wave Amp", float) = 1
        _WaveSpeed("Wave Speed", float) = 1
        _SurfaceDistortion("Surface Distortion Texture", 2D) = "white" {}
        _SurfaceMoveSpeed("Surface Move Speed (only uses X & Y)", Vector) = (0.03, 0.03, 0, 0)
        _SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.27
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "Transparent" "LightMode"="ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM
            #define SMOOTHSTEP_AA 0.01
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform float4 _LightColor0;

            float4 alphaBlend(float4 top, float4 bottom)
            {
                float3 color = (top.rgb * top.a) + (bottom.rgb * (1 - top.a));
                float alpha = top.a + bottom.a * (1 - top.a);

                return float4(color, alpha);
            }

            // Vertex Input (known as appdata)
            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            // Vertex Output (aka v2f)
            struct vertexOutput
            {
                float4 vertex : SV_POSITION;
                float4 col : COLOR;

                float2 noiseUV : TEXCOORD0;
                float2 distortUV : TEXCOORD1;
                float4 screenPosition : TEXCOORD2;
                float3 viewNormal : NORMAL;
                float fresnel : TEXCOORD3;
            };

            sampler2D _SurfaceNoise;
            float4 _SurfaceNoise_ST;

            float _SurfaceNoiseCutoff;
            
            float _FoamDistanceMax;
            float _FoamDistanceMin;

            sampler2D _SurfaceDistortion;
            float4 _SurfaceDistortion_ST;

            float _SurfaceDistortionAmount;

            float4 _FoamColour;

            sampler2D _NoiseTex;
            float _WaveSpeed;
            float _WaveAmp;

            // float3 _WorldSpaceCameraPos;

            // Actual vertex fucntion of type 'v2f' - this would be changed to whatever the vertex output function is.
            // As parameter it takes in the vertex input function.
            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = mul(UNITY_MATRIX_VP, worldPos);

                float noiseSample = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0));
                o.vertex.y += sin(_Time * _WaveSpeed * noiseSample) * _WaveAmp;
                o.vertex.x += cos(_Time * _WaveSpeed * noiseSample) * _WaveAmp;

                o.screenPosition = ComputeScreenPos(o.vertex);
                o.noiseUV = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);
                o.viewNormal = COMPUTE_VIEW_NORMAL;

                // Light calculation
                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject;

                float3 normalDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuseReflection = _LightColor0.rgb * max(0.0, dot(normalDirection, lightDirection));

                o.col = float4(diffuseReflection, 1.0);

                return o;
            }

            sampler2D _CameraDepthTexture;
            sampler2D _CameraNormalsTexture;

            float4 _ShallowColour;
            float4 _DeepColour;
            float _DepthMaxDistance;

            float2 _SurfaceMoveSpeed;

            float getDepthDifference(vertexOutput i)
            {
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
                float existingDepthLinear = LinearEyeDepth(existingDepth01);
                float depthDifference = existingDepthLinear - i.screenPosition.w;
                
                return depthDifference;
            }

            // Actual fragment function, it takes in the vertex output as the parameter.
            // SV_Target is used by DX10+ for fragment shader colour output.
            // If this was targeted for DX9, instead of SV_Target, COLOR would be used.
            // It is preferable to use SV_Target anyways, as then it can be assigned to what is required.
            float4 frag(vertexOutput i) : SV_Target
            {
                float depthDifference = getDepthDifference(i);

                float waterDepthDifference = saturate(depthDifference / _DepthMaxDistance);
                float4 waterColour = lerp(_ShallowColour, _DeepColour, waterDepthDifference);

                float2 distortSample = (tex2D(_SurfaceDistortion, i.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;

                float2 noiseUV = float2((i.noiseUV.x + _Time.y * _SurfaceMoveSpeed.x) + distortSample.x,
                    (i.noiseUV.y + _Time.y * _SurfaceMoveSpeed.y) + distortSample.y);
                
                float surfaceNoiseSample = tex2D(_SurfaceNoise, noiseUV).r;

                float3 existingNormal = tex2Dproj(_CameraNormalsTexture, UNITY_PROJ_COORD(i.screenPosition));
                float3 normalDot = saturate(dot(existingNormal, i.viewNormal));

                float foamDistance = lerp(_FoamDistanceMax, _FoamDistanceMin, normalDot);
                float foamDepthDifference01 = saturate(depthDifference / foamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;

                float surfaceNoise = smoothstep(surfaceNoiseCutoff - SMOOTHSTEP_AA,
                    surfaceNoiseCutoff + SMOOTHSTEP_AA, surfaceNoiseSample);
                float4 surfaceNoiseColour = _FoamColour;
                surfaceNoiseColour.a *= surfaceNoise;

                float4 blend = alphaBlend(surfaceNoiseColour, waterColour);
                blend *= i.col;

                return blend;
            }

            ENDCG
        }
    }
}