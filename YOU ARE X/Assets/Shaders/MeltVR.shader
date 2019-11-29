Shader "MeltVR" {
	Properties {
	 	_MainTex ("", 2D) = "white" {}
	}
	SubShader {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        
	 	Pass {
            // distort previous accumulation buffer and overwrite into current accumulation buffer

            // TODO: get proper alpha blending working

            Blend Off

	  		CGPROGRAM
	  		#pragma vertex vert_img
	  		#pragma fragment frag
	  		#include "UnityCG.cginc"
            #include "ClassicNoise3D.hlsl"

	  		uniform sampler2D _MainTex;
            uniform sampler2D _SourceTex; 

            /*
            uniform float4x4 _VPCurrentInverse;
            uniform float4x4 _VPPast;
            */

            int antiAliasing;
            float scaleDistortion;
            float scaleFlow;
            float scaleTurbulence;
            float speedDistortion;
            float speedFlow;
            float speedTurbulence;
            float amountDistortion;
            float amountFlow;
            float amountTurbulence;

            float4 _MainTex_TexelSize;

            /*

            float2 cameraDeltaUV(float2 screenSpaceUV) {
                float3 screenSpaceCurrent = float3(screenSpaceUV * 2.0 - float2(1.0, 1.0), 1.0);
                float4 worldSpaceCurrent = float4(mul(_VPCurrentInverse, screenSpaceCurrent).xyz, 1.0);
                float3 screenSpacePrevious = mul(_VPPast, worldSpaceCurrent);

                return screenSpaceCurrent.xy - screenSpacePrevious.xy;
            }

            */

            float2 distort(float2 coord) {                    
                float2 noiseDistortion = float2(
                    cnoise(float3(scaleDistortion * (coord), _Time.y * speedDistortion)), 
                    cnoise(float3(scaleDistortion * (coord +  float2(1.0, 1.0)), _Time.y * speedDistortion))
                );

                float2 noiseFlow = amountFlow * unity_DeltaTime.z * float2(
                    cnoise(float3(scaleFlow * (coord + noiseDistortion * amountDistortion), _Time.y * speedFlow)), 
                    cnoise(float3(scaleFlow * (coord + noiseDistortion * amountDistortion +  float2(1.0, 1.0)), _Time.y * speedFlow))
                );

                float2 noiseTurbulence = amountTurbulence * unity_DeltaTime.z * float2(
                    cnoise(float3(scaleTurbulence * (coord + noiseDistortion * amountDistortion), _Time.y * speedTurbulence)), 
                    cnoise(float3(scaleTurbulence * (coord + noiseDistortion * amountDistortion +  float2(1.0, 1.0)), _Time.y * speedTurbulence))
                );

                return noiseFlow * amountFlow + noiseTurbulence * amountTurbulence;
            }

            fixed4 blend(fixed4 top, fixed4 bottom) {
                fixed4 output = 0;
                output.a = top.a + bottom.a * (1.0 - top.a);
                output.rgb = (top.rgb * top.a + bottom.rgb * bottom.a * (1.0 - top.a)) / output.a;
                if(output.a < 0.0001) {
                    output.rgb = 0;
                }
                return output;
            }

	  		fixed4 frag(v2f_img i) : COLOR {
                float2 delta = distort(i.uv);
                float2 coord = i.uv;// - 2.0 * cameraDeltaUV(i.uv);
                float norm = length(i.uv);

                fixed4 result = 0;

                for(int count = 0; count < antiAliasing; count++) {
                    result += tex2D(_MainTex, coord + delta * (count + 1.0 ) / (antiAliasing * 1.0)).rgba;
                }

                return result / (1.0 * antiAliasing) * exp(- unity_DeltaTime.z - 0.03);

                //return float4(cameraDeltaUV(i.uv), 0.0, 1.0);

            }
	  		ENDCG
	 	}
        
        Pass {
            // copy camera image over current accumulation buffer with alpha

            Blend SrcAlpha One 

            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            uniform sampler2D _SourceTex;

            fixed4 frag(v2f_img i) : COLOR {
                return fixed4(tex2D(_SourceTex, i.uv).rgba);
            }
            ENDCG
        }
	}
}