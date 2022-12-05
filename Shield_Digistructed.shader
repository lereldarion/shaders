Shader "Custom/Shield_Digistructed"
{
    Properties
    {
		[Header (Zero alpha for fallback)]
        _Color ("Color", Color) = (1,1,1,0)
		
		[Header (Emission)]
		_EmissionMap ("Map", 2D) = "black" {}
		[HDR] _EmissionColor ("Color", Color) = (0, 0, 0)

		[Header (Digistruct Effect)]
		_DS_Radius ("Clip radius", float) = 1
		_DS_TransitionThickness ("Transition thickness", float) = 1
		_DS_TransitionColor ("Transition color", Color) = (1, 1, 1)
    }
    SubShader
    {
        Tags {
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
			"ForceNoShadowCasting" = "True"
			"VRCFallback" = "Standard"
		}
        LOD 200
		
		Cull Off // Show both sides
		Blend One One

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"

			sampler2D _EmissionMap;
			uniform half3 _EmissionColor;

			uniform float _DS_Radius;
			uniform float _DS_TransitionThickness;
			uniform half3 _DS_TransitionColor;

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 object_vertex : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			v2f vert (appdata v) {
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.vertex = UnityObjectToClipPos (v.vertex);
				o.uv = v.uv;
				o.object_vertex = v.vertex.xyz;
				return o;
			}

			fixed4 frag (v2f v) : SV_Target {
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX (v);
			
				float distance_to_origin = length (v.object_vertex);
				clip (_DS_Radius - distance_to_origin);

				if (distance_to_origin > _DS_Radius - _DS_TransitionThickness) {
					return fixed4 (_DS_TransitionColor, 1);
				} else {
					return fixed4 (tex2D (_EmissionMap, v.uv) * _EmissionColor, 1);
				}
			}

			ENDCG
		}
    }
    FallBack "Standard"
}
