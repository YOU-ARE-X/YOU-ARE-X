Shader "Custom/ScanningElectron" {
    Properties {
        _DetectorDirection ("Detector Direction", Vector) = (1.0,-2.0,1.0)
        _ParallaxStrength ("Parallax Strength", Range (0.0, 2.0)) = 0.4
        _NormalStrength ("Normal Strength", Range (0.0, 2.0)) = 1.0
        [Header(Static Texture Settings)] 
        [Toggle] _StaticTexEnable("Enable", Float) = 0
        _NormalTex ("Normal Texture", 2D) = "" {}
        _HeightTex ("Height Texture", 2D) = "" {}
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
            float _ParallaxStrength;
            float _NormalStrength;
            uniform sampler2D _NormalTex;
            uniform sampler2D _HeightTex;
            float _StaticTexEnable;
            float _Scale;
            float _ScaleCoarse;
            float _ScaleMedium;
            float _ScaleFine;
            float _DistCoarse;
            float _DistMedium;
            float _AmountCoarse;
            float _AmountMedium;
            float _AmountFine;

            float tanhNormalized(float x) {
                return 0.5 * (tanh(2.0 * x - 1.0) + 1.0);
            }

            float heightMap(float2 uv) {
                if(_StaticTexEnable == 0) {
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
                    
                    return tanhNormalized(
                        noiseCoarse * _AmountCoarse +
                        noiseMedium * _AmountMedium +
                        noiseFine * _AmountFine
                    );
                } else {
                    // use height texture
                    return tex2D(_HeightTex, float4(uv, 0, 0)).x;
                    //return tex2D(_HeightTex, uv).x;
                }
            }

            float3 normalMap(float3 normal, float4 tangent, float2 uv) {
                // tangent-space normal vector

                float3 bump;

                if(_StaticTexEnable == 0) {
                    // use procedural height map

                    // apply sobel filter to height function

                    // differentiation uv increment for sobel filter
                    float delta = 0.01;

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
                    float dz = 1.0 / _NormalStrength;

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

            float2 parallaxMap(float3 normal, float4 tangent, float2 uv, float3 viewDirection) {
                // transform viewDirection to tangent space

                float3 bitangent = cross(normal, tangent.xyz) * tangent.w;

                float3x3 worldToTangent = float3x3(tangent.xyz, bitangent, normal);

                float3 viewDirectionTangent = normalize(mul(worldToTangent, viewDirection));
                
                // hunt for the intersection of the incoming ray with the depth-mapped face
                // iterate through height slices from 0.0 to -1.0

                const int layerCount = 16;
                
                float2 layerUVDelta = viewDirectionTangent.xy * _ParallaxStrength / ((float) layerCount);
                float2 layerUVCurrent = uv;
                float2 layerUVLast = layerUVCurrent;

                float layerDepthDelta = 1.0 / ((float) layerCount);
                float layerDepthCurrent = 0.0;
                float layerDepthLast = layerDepthCurrent;

                float layerDepthMapCurrent = 1.0 - heightMap(layerUVCurrent);
                float layerDepthMapLast = layerDepthMapCurrent;

                for(int i = 0; i < layerCount && layerDepthCurrent < layerDepthMapCurrent; i++) {
                    layerUVLast = layerUVCurrent;
                    layerUVCurrent -= layerUVDelta;

                    layerDepthMapLast = layerDepthMapCurrent;
                    layerDepthMapCurrent = 1.0 - heightMap(layerUVCurrent);

                    layerDepthLast = layerDepthCurrent;
                    layerDepthCurrent += layerDepthDelta;
                }
                
                // interpolate between two best matches
                
                float weightCurrent = abs(layerDepthMapCurrent - layerDepthCurrent);
                float weightLast = abs(layerDepthMapLast - layerDepthLast);
                float weightSum = weightCurrent + weightLast;
                weightCurrent = 1.0 - weightCurrent / weightSum;
                weightLast = 1.0 - weightLast / weightSum;

                float2 interpolatedUV = weightCurrent * layerUVCurrent + weightLast * layerUVLast;

                // return computed uv

                return interpolatedUV;
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
                o.normal = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0.0)).xyz); //Calculate the normal
                o.tangent = normalize(mul(unity_ObjectToWorld, v.tangent)); //Calculate the normal
                o.pos = UnityObjectToClipPos(v.vertex); //And the position
                o.uv = v.uv;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 detectorDirection = normalize(_DetectorDirection.xyz);
                float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                float2 uvParallax = parallaxMap(i.normal, i.tangent, i.uv, viewDirection);
                float3 normalDirection = normalize(normalMap(i.normal, i.tangent, uvParallax));

                fixed brightness = 1.0 / (dot(normalDirection, detectorDirection) + 2.0);

                return fixed4(brightness, brightness, brightness, 1.0);
                //return fixed4(uvParallax.xy, 0.0, 1.0);

                //return fixed4(1.0 / (dot(normalDirection, detectorDirection) + 1.0), 0.0, 0.0, 1.0);
            }

            ENDCG
        }
    }
}