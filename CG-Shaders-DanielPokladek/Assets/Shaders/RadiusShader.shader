Shader "Daniel/Effects/RadiusShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_Center("Radius Center", Vector) = (0,0,0,0)
		_Radius("Radius", Float) = 0.5
		_RadiusColor("Radius Color", Color) = (1,0,0,1)
		_RadiusWidth("Radius Width", Float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.5

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;  // UV of the terrain texture 
            float3 worldPos;    // In-World position
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

		// Radius Properties
		float3 _Center;
		float _Radius;
		float _RadiusWidth;
		fixed4 _RadiusColor;
        

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float d = distance(_Center, IN.worldPos);
            
            if (d > _Radius && d < _Radius + _RadiusWidth)
            {
                o.Albedo = _RadiusColor;
            }
            else
            {
                fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
            }
            
            // Albedo comes from a texture tinted by color
            //fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            //o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
