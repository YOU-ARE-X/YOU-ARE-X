// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ScanningElectron" {
    Properties {
        _DetectorDirection ("Detector Direction", Vector) = (1.0,-2.0,1.0)
        [Header(Static Texture Settings)] 
        [Toggle] _NormalTexEnable("Enable", Float) = 0
        _NormalTex ("Normal Texture", 2D) = "" {}
        [Header(Procedural Texture Settings)] 
        [PowerSlider(2.0)] _Scale           ("Scale Global", Range (0.0, 100.0)) = 10.0
        [PowerSlider(2.0)] _ScaleCoarse     ("Scale Coarse", Range (0.0, 1.0)) = 0.4
        [PowerSlider(2.0)] _ScaleMedium     ("Scale Medium", Range (1.0, 10.0)) = 3.0
        [PowerSlider(2.0)] _ScaleFine       ("Scale Fine", Range (10.0, 100.0)) = 70
        _DistCoarse      ("Distortion Coarse", Range (0.0, 5.0)) = 0.6
        _DistMedium      ("Distortion Medium", Range (0.0, 5.0)) = 3.0
        _AmountCoarse    ("Amount Coarse", Range (0.0, 5.0)) = 0.4
        _AmountMedium    ("Amount Medium", Range (0.0, 5.0)) = 0.1
        _AmountFine      ("Amount Fine", Range (0.0, 5.0)) = 0.02
    }
    SubShader {

        // fallback necessary for ambient occlusion
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "ClassicNoise2D.hlsl"

            float3 _DetectorDirection;
            uniform sampler2D _NormalTex;
            float _NormalTexEnable;
            float _Scale;
            float _ScaleCoarse;
            float _ScaleMedium;
            float _ScaleFine;
            float _DistCoarse;
            float _DistMedium;
            float _AmountCoarse;
            float _AmountMedium;
            float _AmountFine;

            float heightMap(float2 uv) {
                // generate height map with perlin noise
                
                float2 uvShifted = uv + float2(1.0, 1.0);

                float2 noiseDistCoarse = float2(
                    cnoise(_Scale * _ScaleCoarse * uv), 
                    cnoise(_Scale * _ScaleCoarse * uvShifted)
                );
                float noiseCoarse = noiseDistCoarse.x;

                // coarse noise distorts medium noise
                
                float2 noiseDistMedium = float2(
                    cnoise(_Scale * (_ScaleMedium * uv + noiseDistCoarse * _DistCoarse)), 
                    cnoise(_Scale * (_ScaleMedium * uvShifted + noiseDistCoarse * _DistCoarse)) 
                );
                float noiseMedium = noiseDistMedium.x;

                // medium noise distorts fine noise

                float noiseFine = 
                    cnoise(_Scale * (_ScaleFine * uv + noiseDistMedium * _DistMedium));

                // final result is a weighted sum of all three noise types
                
                return 
                    noiseCoarse * _AmountCoarse +
                    noiseMedium * _AmountMedium +
                    noiseFine * _AmountFine;
            }

            float3 normalMap(float3 normal, float4 tangent, float2 uv) {
                // apply sobel filter to height function
                // apply normal map on face normal

                float3 bump;

                if(_NormalTexEnable == 0) {
                    // use procedural height map

                    // differentiation uv increment for sobel filter
                    float delta = 0.01;

                    // strength of height map
                    float strength = 1.0;

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

                    bump = normalize(float3(dx, dy, dz));
                } else {
                    // use texture for normal map
                    
                    bump = tex2D(_NormalTex, uv) * 2.0 + float3(1.0, 1.0, 1.0);
                }

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
                float3 normalDirection = normalize(normalMap(i.normal, i.tangent, i.uv));
                float3 detectorDirection = normalize(_DetectorDirection.xyz);
                //float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                fixed brightness = 1.0 / (dot(normalDirection, detectorDirection) + 2.0);

                return fixed4(brightness, brightness, brightness, 1.0);

                //return fixed4(1.0 / (dot(normalDirection, detectorDirection) + 1.0), 0.0, 0.0, 1.0);
            }

            ENDCG
        }
    }
}