Shader "Melt" {
	Properties {
	 	_MainTex ("", 2D) = "white" {}
	}
	SubShader {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        
	 	Pass {
            // distort previous accumulation buffer and overwrite into current accumulation buffer

            // TODO: get a better distortion vector field, either procedural or as a texture

            Blend Off

	  		CGPROGRAM
	  		#pragma vertex vert_img
	  		#pragma fragment frag
	  		#include "UnityCG.cginc"
            #include "ClassicNoise3D.hlsl"

            static const float PI = 3.14159;

	  		uniform sampler2D _MainTex;
            uniform sampler2D _SourceTex; 

            float2 remap(float2 coord) {
                //return coord + 0.01 * float2(sin(coord.x * PI * 5), sin(coord.y * PI * 5));
                return coord + 
                0.01 * float2(
                    cnoise(float3(5.0 * coord, _Time.y * 0.5)), 
                    cnoise(float3(5.0 * (coord + float2(1.0, 1.0)), _Time.y * 0.5))
                ) + 
                0.0003 * float2(
                    cnoise(float3(40.0 * coord, _Time.y * 0.5)), 
                    cnoise(float3(40.0 * (coord + float2(1.0, 1.0)), _Time.y * 3.0))
                );
            }

            fixed4 blend(float4 over, float4 under) {
                float4 result;
                result.a = over.a + under.a * (1.0 - over.a);
                result.rgb = (over.rgb * over.a + under.rgb * under.a * (1.0 - over.a)) / result.a;
                if(result.a < 0.0001) {
                    result.rgb = float3(0, 0, 0);
                }
                return result;
            }

            fixed4 compose(float4 source, float4 accum) {
                return source + accum;
            }

	  		fixed4 frag(v2f_img i) : COLOR {
			    return compose(tex2D(_SourceTex, i.uv), 0.95 * fixed4(tex2D(_MainTex, remap(i.uv)).rgba));
	  		}
	  		ENDCG
	 	}
	}
}