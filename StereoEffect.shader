Shader "Custom/StereoColor"
{
    Properties
    {
    }
    SubShader
    {
        Tags {
			"RenderType"="Transparent"
			"Queue"="Transparent"
		}
		
		// https://docs.unity3d.com/2019.3/Documentation/Manual/SL-CullAndDepth.html
		ZWrite Off // TODO test on ?
		Blend SrcAlpha OneMinusSrcAlpha // Sufficient for now

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_instancing
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
            };


            v2f vert (appdata v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				
                return lerp(
					fixed4(1,0,0,0.5), // Left color
					fixed4(0,0,1,0.5), // Right color
					unity_StereoEyeIndex
				);
            }
            ENDCG
        }
    }
}