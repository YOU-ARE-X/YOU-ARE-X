// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Gas" {
    Properties {
        _Falloff      ("Falloff", Range (1.0, 10.0)) = 3.0
        _Brightness   ("Brightness", Range (0.0, 1.0)) = 1.0
    }
    SubShader {

        // fallback necessary for ambient occlusion
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc" 

            float _Falloff;
            float _Brightness;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float3 normalWorld : NORMAL;
                float4 posWorld : TEXCOORD1;
                float4 pos : POSITION;
            };

            v2f vert(appdata v) {
                v2f o;

                o.normalWorld = normalize(mul(v.normal, unity_WorldToObject));
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                
                float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                // must re-normalize because interpolation doesn't produce vectors with identical length
                float3 normalWorld = normalize(i.normalWorld);

                fixed brightness = pow(dot(viewDirection, normalWorld), _Falloff) * _Brightness;

                // calculation above can result in +infinity, clamp back to a reasonable range
                if(brightness > 1.0) {
                    brightness = 1.0;
                }

                return fixed4(brightness, brightness, brightness, 1.0);
            }

            ENDCG
        }
    }
}
