// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/ScanningElectron" {
    Properties {
        [Header(General Settings)] 
        _DetectorDirection ("Detector Direction", Vector) = (1.0, -1.0, 0.0, 0.0)
        [Toggle] _ParallaxEnable("Parallax Enable", Float) = 0
        _ParallaxStrength ("Parallax Strength", Range (0.0, 2.0)) = 0.4
        _NormalStrength ("Normal Strength", Range (0.0, 2.0)) = 1.0
        [Header(Static Texture Settings)] 
        [Toggle] _StaticTexEnable("Enable", Float) = 0
        _NormalTex ("Normal Texture", 2D) = "" {}
        _HeightTex ("Height Texture", 2D) = "" {}
        [Header(Procedural Texture Settings)] 
        [PowerSlider(2.0)] _Scale           ("Scale Global", Range (0.0, 100.0)) = 10.0
        [PowerSlider(2.0)] _ScaleCoarse     ("Scale Coarse", Range (0.0, 4.0)) = 0.4
        [PowerSlider(2.0)] _ScaleMedium     ("Scale Medium", Range (2.0, 8.0)) = 3.0
        [PowerSlider(2.0)] _ScaleFine       ("Scale Fine", Range (4.0, 64.0)) = 60
        _DistCoarse      ("Distortion Coarse", Range (0.0, 5.0)) = 0.6
        _DistMedium      ("Distortion Medium", Range (0.0, 5.0)) = 3.0
        _AmountCoarse    ("Amount Coarse", Range (0.0, 5.0)) = 0.4
        _AmountMedium    ("Amount Medium", Range (0.0, 5.0)) = 0.1
        _AmountFine      ("Amount Fine", Range (0.0, 5.0)) = 0.02
        _OffsetHeight    ("Offset", Range (-2.0, 2.0)) = 0.0
    }
    SubShader {

        // fallback necessary for ambient occlusion
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members binormalWorld)
#pragma exclude_renderers d3d11

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "ClassicNoise2D.hlsl"

            uniform float3 _DetectorDirection;
            uniform float _ParallaxEnable;
            uniform float _ParallaxStrength;
            uniform float _NormalStrength;
            uniform sampler2D _NormalTex;
            uniform sampler2D _HeightTex;
            uniform float _StaticTexEnable;
            uniform float _Scale;
            uniform float _ScaleCoarse;
            uniform float _ScaleMedium;
            uniform float _ScaleFine;
            uniform float _DistCoarse;
            uniform float _DistMedium;
            uniform float _AmountCoarse;
            uniform float _AmountMedium;
            uniform float _AmountFine;
            uniform float _OffsetHeight;

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
                        _OffsetHeight +
                        noiseCoarse * _AmountCoarse +
                        noiseMedium * _AmountMedium +
                        noiseFine * _AmountFine
                    );
                } else {
                    // use height texture
                    //return tex2D(_HeightTex, float4(uv, 0, 0)).x;
                    return tex2D(_HeightTex, uv).x;
                }
            }

            float3 normalMap(float3 normal, float4 tangent, float3 binormal, float2 uv) {
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
                    
                    bump = tex2D(_NormalTex, uv) * 2.0 - float3(1.0, 1.0, 1.0);
                }

                // apply bump vector on fragment normal

                return bump.x * tangent + bump.y * binormal + bump.z * normal;
            }

            float2 parallaxMap(float3 normal, float4 tangent, float3 binormal, float2 uv, float3 viewDirection) {
                // transform viewDirection to tangent space
                
                float3x3 worldToTangent = float3x3(tangent.xyz, binormal, normal);
                float3 viewDirectionTangent = normalize(mul(worldToTangent, viewDirection));
                
                // hunt for the intersection of the incoming ray with the depth-mapped face
                // iterate through height slices from 0.0 to -1.0

                const int layerCount = 32;
                
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
                float3 normalWorld : NORMAL;
                float4 tangentWorld : TANGENT;
                float3 binormalWorld : BINORMAL;
                float4 posWorld : TEXCOORD1;
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v) {
                v2f o;

                o.normalWorld = normalize(mul(v.normal, unity_WorldToObject));
                o.tangentWorld = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0)));
                o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 cameraLeft = normalize(UNITY_MATRIX_IT_MV[0].xyz);
                float3 cameraUp = normalize(UNITY_MATRIX_IT_MV[1].xyz);
                float3 cameraFront = normalize(UNITY_MATRIX_IT_MV[2].xyz);

                float3 detectorDirection = normalize(
                    _DetectorDirection.x * cameraFront + 
                    _DetectorDirection.y * cameraUp +
                    _DetectorDirection.z * cameraLeft
                );

                float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                // must re-normalize because interpolation doesn't produce vectors with identical length
                float3 normalWorld = normalize(i.normalWorld);
                float4 tangentWorld = normalize(i.tangentWorld);
                float3 binormalWorld = normalize(i.binormalWorld);

                float2 uvMapped;

                if(_ParallaxEnable != 0) {
                    // use parallax mapping
                    uvMapped = parallaxMap(normalWorld, tangentWorld, binormalWorld, i.uv, viewDirection);
                } else {
                    // don't use parallax mapping
                    uvMapped = i.uv;
                }
                
                float3 normalMapped = normalize(normalMap(normalWorld, tangentWorld, binormalWorld, uvMapped));

                fixed brightness = 1.0 / (dot(normalMapped, detectorDirection) + 2.0);

                return fixed4(brightness, brightness, brightness, 1.0);
            }

            ENDCG
        }
    }
}