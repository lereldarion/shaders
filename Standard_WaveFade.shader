Shader "Custom/Standard_WaveFade"
{
	// Standard shader with progressive deployement effect
	// Effect = cutoff based on radius in object space + emission band on the cutoff front
	// Only supports part of standard shader used by sword.
	// Designed to fallback directly to standard shader without the cutoff
		
    Properties
    {
		[Header (Standard shader parameters)]
        _MainTex ("Albedo", 2D) = "white" {}
		
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_MetallicGlossMap ("Metallic", 2D) = "white" {}
		
		[Header (Fade Effect)]
		_DS_Radius ("Clip radius", float) = 1
		_DS_TransitionThickness ("Transition thickness", float) = 1
		_DS_TransitionColor ("Transition color", Color) = (1, 1, 1)
    }
    SubShader
    {
        Tags {
			"RenderType" = "Opaque"
			"VRCFallback" = "Standard"
		}
        LOD 350
		
        CGPROGRAM
		
		// standard : lighting mode
        #pragma surface surf Standard vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;
		
		uniform half _Glossiness;
		uniform half _Metallic;
		sampler2D _MetallicGlossMap;
		
		uniform float _DS_Radius;
		uniform float _DS_TransitionThickness;
		uniform half3 _DS_TransitionColor;

        struct Input {
            float2 uv_MainTex;
			float2 uv_MetallicGlossMap;
			float3 vertex;
        };
		
		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT (Input, o);
			o.vertex = v.vertex.xyz;
		}

        void surf (Input IN, inout SurfaceOutputStandard o) {
			float distance_to_origin = length (IN.vertex);
			
			clip (_DS_Radius - distance_to_origin);

			if (distance_to_origin > _DS_Radius - _DS_TransitionThickness) {
				o.Emission = _DS_TransitionColor;
			}
			
			// Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
						
            // Metallic and smoothness come from slider variables / metallic map (r+a)
			half4 metallic_and_smoothness = tex2D (_MetallicGlossMap, IN.uv_MetallicGlossMap);
            o.Metallic = metallic_and_smoothness.r * _Metallic;
            o.Smoothness = metallic_and_smoothness.a * _Glossiness;
        }
		
        ENDCG
    }
    FallBack "Standard"
}
