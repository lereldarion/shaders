Shader "Custom/BleedOverlay3D"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_Radius ("Radius", float) = 0.5
		_BlendRadius ("Blend Radius", float) = 0.2
    }
    SubShader
    {
        Tags {
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
			"VRCFallback" = "Hidden"
		}
		
		// https://docs.unity3d.com/2019.3/Documentation/Manual/SL-CullAndDepth.html
		ZWrite Off // For transparent mats
		Blend SrcAlpha OneMinusSrcAlpha // Sufficient for now

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_instancing
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
				
				float2 screen_pos : TEXCOORD0;
				float3 world_dir : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
            };

			uniform fixed4 _Color;
			uniform float _Radius;
			uniform float _BlendRadius;

            v2f vert (appdata v) {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
                o.vertex = UnityObjectToClipPos(v.vertex);
				
				// https://github.com/cnlohr/shadertrixx#depth-textures--getting-worldspace-info
				o.world_dir = mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos;
				float2 screen_uv = o.vertex * float2(0.5, 0.5 * _ProjectionParams.x);
				o.screen_pos = TransformStereoScreenSpaceTex(screen_uv + 0.5 * o.vertex.w, o.vertex.w);
				
                return o;
            }
			
			// Macro required: https://issuetracker.unity3d.com/issues/gearvr-singlepassstereo-image-effects-are-not-rendering-properly
			// Requires a source of dynamic light to be populated https://github.com/netri/Neitri-Unity-Shaders#types ; sad...
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            fixed4 frag (v2f i) : SV_Target {
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX (i);
				
				// https://github.com/cnlohr/shadertrixx#depth-textures--getting-worldspace-info
				float perspective_divide = 1.0f / i.vertex.w;
				float2 screen_uv = i.screen_pos * perspective_divide;
				float depth = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE (_CameraDepthTexture, screen_uv));
				float3 direction = i.world_dir * perspective_divide;
				float3 worldspace = direction * depth + _WorldSpaceCameraPos;
				float3 objectspace = mul (unity_WorldToObject, float4(worldspace, 1)).xyz;

				// Blend transition with blend radius
				float impact = smoothstep (0, _BlendRadius, _Radius - length (objectspace));
				
                return _Color * impact;
            }
			
            ENDCG
        }
    }
}
