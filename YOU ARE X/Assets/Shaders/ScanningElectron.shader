// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ScanningElectron" {
    SubShader {

        // fallback necessary for ambient occlusion
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "ClassicNoise2D.hlsl"

            float heightMap(float2 uv) {
                // generate height map with perlin noise

                float noise;
            
                noise =  0.2 * cnoise(0.5  * (uv));
                noise =  0.2 * cnoise(4.0  * (uv + 5.0 * noise));
                noise += 0.02 * cnoise(70.0 * (uv + 0.1 * noise));

                return noise;
            }

            float3 normalBumpMap(float3 normal, float4 tangent, float2 uv, float delta, float strength) {
                // apply sobel filter to height function
                // apply normal map on face normal

                float tl = heightMap(uv + float2(- delta, - delta)); // top left
                float cl = heightMap(uv + float2(- delta,       0)); // center left
                float bl = heightMap(uv + float2(- delta, + delta)); // bottom left

                float tc = heightMap(uv + float2(      0, - delta)); // top center
                float bc = heightMap(uv + float2(      0, + delta)); // bottom center

                float tr = heightMap(uv + float2(+ delta, - delta)); // top right
                float cr = heightMap(uv + float2(+ delta,       0)); // center right
                float br = heightMap(uv + float2(+ delta, + delta)); // bottom right

                float dx = (tr + 2.0 * cr + br) - (tl + 2.0 * cl + bl);
                float dy = (bl + 2.0 * bc + br) - (tl + 2.0 * tc + tr);
                float dz = 1.0 / strength;

                // compute bump vector using sobel filter

                float3 bump = normalize(float3(dx, dy, dz));

                // apply bump vector on fragment normal

                float3 bitangent = cross(normal, tangent.xyz ) * tangent.w;

                return bump.x * tangent + bump.y * bitangent + bump.z * normal;

            }

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 posWorld : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v) {
                v2f o;

                o.posWorld = mul(unity_ObjectToWorld, v.vertex); //Calculate the world position for our point
                //o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); //Calculate the normal
                o.pos = UnityObjectToClipPos(v.vertex); //And the position
                o.normal = v.normal;
                o.tangent = v.tangent;
                o.uv = v.uv;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 normalDirection = normalize(normalBumpMap(i.normal, i.tangent, i.uv, 0.01, 1.0));
                float3 detectorDirection = normalize(float3(1.0, -2.0, 1.0));
                //float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                fixed brightness = 1.0 / (dot(normalDirection, detectorDirection) + 1.0);

                return fixed4(brightness, brightness, brightness, 1.0);

                //return fixed4(1.0 / (dot(normalDirection, detectorDirection) + 1.0), 0.0, 0.0, 1.0);
            }

            ENDCG
        }
    }
}