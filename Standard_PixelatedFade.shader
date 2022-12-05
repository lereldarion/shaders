Shader "Custom/Standard_PixelatedFade"
{
	// Standard shader with progressive deployement effect, around random pixel mapping
	// Effect = cutoff based on random_pixel_weight - time, + emission after cutoff
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
		_Fade_Progress ("Progress", Range (0, 1)) = 0.5
		_Fade_Object_Scale ("Scaling factor of noise on object coordinates", Vector) = (1, 1, 1)
		_Fade_Emission_Color ("Emission color", Color) = (1, 1, 1)
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
		
		uniform float _Fade_Progress;
		uniform float3 _Fade_Object_Scale;
		uniform half3 _Fade_Emission_Color;

        struct Input {
            float2 uv_MainTex;
			float2 uv_MetallicGlossMap;
			float3 vertex;
        };
		
		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT (Input, o);
			o.vertex = v.vertex.xyz;
		}

		// https://stackoverflow.com/questions/15628039/simplex-noise-shader
		float hash( float n ) {
			return frac (sin (n) * 43758.5453);
		}
		float noise ( float3 x ){
			// The noise function returns a value in the range -1.0f -> 1.0f
			float3 p = floor (x);
			float3 f = frac (x);

			f = f * f * (3.0 - 2.0 * f);
			float n = p.x + p.y * 57.0 + 113.0 * p.z;

			return lerp(lerp(lerp( hash(n+0.0), hash(n+1.0),f.x),
						lerp( hash(n+57.0), hash(n+58.0),f.x),f.y),
					lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
						lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
		}

        void surf (Input i, inout SurfaceOutputStandard o) {
			float noise_raw = noise (i.vertex * _Fade_Object_Scale); // [-1, 1]
			//float noise_01 = 0.5 + 0.5 * noise_raw;
			float progress_of_pixel = _Fade_Progress - noise_raw;
			
			// hide pixels with low noise
			clip (progress_of_pixel);

			// highlight recently unhidden pixels
			half highlight = smoothstep (-0.1, 0, -progress_of_pixel);
			o.Emission = highlight * _Fade_Emission_Color;
			
			// Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, i.uv_MainTex);
            o.Albedo = c.rgb;
						
            // Metallic and smoothness come from slider variables / metallic map (r+a)
			half4 metallic_and_smoothness = tex2D (_MetallicGlossMap, i.uv_MetallicGlossMap);
            o.Metallic = metallic_and_smoothness.r * _Metallic;
            o.Smoothness = metallic_and_smoothness.a * _Glossiness;
        }
		
        ENDCG
    }
    FallBack "Standard"
}
