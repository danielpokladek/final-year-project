Shader "Dissertation/Research/HarryWater"
{
    Properties
    {
        _Smoothness("Smoothness", Range(0, 1)) = 1

        [Header(Colors)]
        _GradientMap("Water Gradient Map", 2D) = "white" {}
        _ShoreColor("Shore Color", Color) = (1,1,1,1)
        _ShoreColorThreshold("Shore Color Threshold", Range(0, 1)) = 0
        [HDR] _Emission("Emission", Color) = (1,1,1,1)

        [Header(Tessellation)]
        _VectorLength("Vector Length", Range(0, 0.2)) = 0.1
        _MaxTessellationDistance("Max Tessellation Distance", float) = 100
        _Tessellation("Tessellation", Range(1.0, 128.0)) = 1.0

        [Header(Vertex Offset)]
        _NoiseATexture("Noise A Texture", 2D) = "white" {}
        _NoiseAProperties("Noise A Properties", Vector) = (0,0,1,1)
        _NoiseBTexture("Noise B Texture", 2D) = "white" {}
        _NoiseBProperties("Noise B Properties", Vector) = (0,0,1,1)
        _OffsetAmount("Offset Amount", Range(0.0, 1.0)) = 1.0
        _MinOffset("Min Offset", Range(0.0, 1.0)) = 0.2

        [Header(Displacement)]
        _DisplacementGuide("Displacement Guide", 2D) = "white" {}
        _DisplacementProperties("Displacement Properties", Vector) = (0,0,0,0)

        [Header(Shore and Foam)]
        _FoamTexture("Foam Texture", 2D) = "white" {}
        _ShoreIntersectionThreshold("Shore Intersection Threshold", float) = 0
        _FoamProperties("Foam Properties", Vector) = (0,0,0,0)
        _FoamIntersectionProperties("Foam Intersection Properties", Vector) = (0,0,0,0)

        [Header(Transparency)]
        _TransparencyIntersectionThresholdMin("Transparency Intersection Threshold Min", float) = 0
        _TransparencyIntersectionThresholdMax("Transparency Intersection Threshold Max", float) = 0
        _TransparencyIntersection("Transparency Intersection Min/Max", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert tessellate:tessDistance alpha:fade addshadow
        #pragma require tessellation tessHW
        #pragma target 3.0

        #include "Tessellation.cginc"

        half _Smoothness;
        float _SmoothnessFresnel;

        sampler2D _GradientMap;
        fixed4 _ShoreColor;
        float _ShoreColorThreshold;
        fixed4 _Emission;

        float _VectorLength;
        float _MaxTessellationDistance;
        float _Tessellation;

        sampler2D _NoiseATexture;
        float4 _NoiseATexture_ST;
        float4 _NoiseAProperties;

        sampler2D _NoiseBTexture;
        float4 _NoiseBTexture_ST;
        float4 _NoiseBProperties; 

        float _OffsetAmount;
        float _MinOffset;

        sampler2D _DisplacementGuide;
        float4 _DisplacementGuide_ST;
        float4 _DisplacementProperties;

        sampler2D _FoamTexture;
        float4 _FoamTexture_ST;
        float4 _FoamProperties;
        float4 _FoamIntersectionProperties;
        float _ShoreIntersectionThreshold;

        float2 _TransparencyIntersection;

        sampler2D _CameraDepthTexture;

        struct Input
        {
            float4 color : Color;
            float3 worldPos;
            float4 screenPos;
        };

        float4 tessDistance(appdata_full v0, appdata_full v1, appdata_full v2)
        {
            float minDist = 10.0;
            float maxDist = _MaxTessellationDistance;

            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tessellation);
        }

        float sampleNoiseTexture(float2 pos, sampler2D noise, float4 props, float2 scale, float2 displ)
        {
            float value = tex2Dlod(noise, float4(pos * scale + displ + _Time.y * props.xy, 0.0, 0.0));
            value = (saturate(lerp(0.5, value, props.z)) * 2.0 - 1.0) * props.w;

            return value;
        }

        float noiseOffset(float2 pos)
        {
            float2 displ = tex2Dlod(_DisplacementGuide,
                float4(pos * _DisplacementGuide_ST.xy + _Time.y * _DisplacementProperties.xy, 0.0, 0.0)).xy;
            displ = ((displ * 2.0) - 1.0) * _DisplacementProperties.z;
            float noiseA = sampleNoiseTexture(pos, _NoiseATexture, _NoiseAProperties, _NoiseATexture_ST.xy, displ);
            float noiseB = sampleNoiseTexture(pos, _NoiseBTexture, _NoiseBProperties, _NoiseBTexture_ST.xy, displ);

            return noiseA * noiseB;
        }

        float smootherstep(float x)
        {
            x = saturate(x);

            return saturate(x * x * x * (x * (6 * x - 15) + 10));
        }

        float remap(float s)
        {
            return (s + 1.0) / 2.0;
        }

        void vert(inout appdata_full v)
        {
            float4 v0 = v.vertex;
            float4 v1 = v0 + float4(_VectorLength, 0.0, 0.0, 0.0);
            float4 v2 = v0 + float4(0.0, 0.0, _VectorLength, 0.0);

            float4 screenPos = ComputeScreenPos(UnityObjectToClipPos(v0.xyz));
            float depth = LinearEyeDepth(tex2Dlod(_CameraDepthTexture, float4(screenPos.xy / screenPos.w, 0.0, 0.0)));
            float diff = smootherstep(saturate((depth - screenPos.w) / _ShoreIntersectionThreshold));
            float thresDiff = max(_MinOffset, diff);
            float factor = thresDiff * _OffsetAmount;

            float vertexOffset = noiseOffset(mul(unity_ObjectToWorld, v0).xz);

            v0.y += vertexOffset * factor;
            v1.y += noiseOffset(mul(unity_ObjectToWorld, v1).xz) * factor;
            v2.y += noiseOffset(mul(unity_ObjectToWorld, v2).xz) * factor;

            float3 vn = cross(v2.xyz - v0.xyz, v1.xyz - v0.xyz);
            v.normal = normalize(vn);

            v.vertex = v0;
            v.color = fixed4(remap(vertexOffset).xxxx);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Displacement
            float2 displ = tex2D(_DisplacementGuide, IN.worldPos.xz * _DisplacementGuide_ST.xy + _Time.y * _DisplacementProperties.xy).xy;
            displ = ((displ * 2.0) - 1.0) * _DisplacementProperties.z;

            // Foam
            float foamTex = tex2D(_FoamTexture, IN.worldPos.xz * _FoamTexture_ST.xy + displ + sin(_Time.y) * _FoamProperties.xy);
            float foam = saturate(foamTex - smoothstep(_FoamProperties.z + _FoamProperties.w, _FoamProperties.z, IN.color.x));

            // Depth Calculation
            float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
            float shoreDepth = smoothstep(0.0, _ShoreColorThreshold, Linear01Depth(depth));
            depth = LinearEyeDepth(depth);
            float foamDiff = smootherstep(saturate((depth - IN.screenPos.w) / _FoamIntersectionProperties.x));
            float shoreDiff = smootherstep(saturate((depth - IN.screenPos.w) / _ShoreIntersectionThreshold));
            float transparencyDiff = smootherstep(saturate((depth - IN.screenPos.w) /
                lerp(_TransparencyIntersection.x, _TransparencyIntersection.y,
                    remap(sin(_Time.y + UNITY_PI / 2.0)))));

            // Shore
            float shoreFoam = saturate(foamTex - smoothstep(_FoamIntersectionProperties.y -
                _FoamIntersectionProperties.z, _FoamIntersectionProperties.y, foamDiff) +
                _FoamIntersectionProperties.w * (1.0 - foamDiff));
            float sandWetness = smoothstep(0.0, 0.3 + 0.2 * remap(sin(_Time.y)), foamDiff);
            shoreFoam *= sandWetness;
            foam += shoreFoam;

            // Colours
            o.Albedo = lerp(lerp(fixed3(0.0, 0.0, 0.0), _ShoreColor.rgb, sandWetness),
                tex2D(_GradientMap, float2(IN.color.x, 0.0)).rgb, shoreDepth) + foam * sandWetness;
            o.Emission = o.Albedo * saturate(_WorldSpaceLightPos0.y) * _LightColor0 * _Emission;
            o.Smoothness = _Smoothness * foamDiff;
            o.Alpha = saturate(lerp(1.0, lerp(0.5, _ShoreColor.a, sandWetness), 1.0 - shoreDiff) * transparencyDiff);
        }

        ENDCG
    }
    FallBack "Diffuse"
}