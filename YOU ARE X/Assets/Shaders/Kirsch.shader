Shader "Kirsch" {
	Properties {
	 	_MainTex ("", 2D) = "white" {}
	}
	SubShader {
	 	Pass {
	  		CGPROGRAM
	  		#pragma vertex vert_img
	  		#pragma fragment frag
	  		#include "UnityCG.cginc"

	  		uniform sampler2D _MainTex;

            float4 _MainTex_TexelSize;

            float luma(fixed3 color) {
                return dot(color, fixed3(0.8, 0.8, 0.8));
            }
            
            float convolve(sampler2D _Tex, float2 loc, float2 delta, float3x3 kernel) {
                return kernel[0][0] * luma(tex2D(_Tex, loc + float2(- delta.x, - delta.y))) + kernel[0][1] * luma(tex2D(_Tex, loc + float2(0, - delta.y))) + kernel[0][2] * luma(tex2D(_Tex, loc + float2(+ delta.x, - delta.y))) +
                       kernel[1][0] * luma(tex2D(_Tex, loc + float2(- delta.x,         0))) + kernel[1][1] * luma(tex2D(_Tex, loc + float2(0,         0))) + kernel[1][2] * luma(tex2D(_Tex, loc + float2(+ delta.x,         0))) +
                       kernel[2][0] * luma(tex2D(_Tex, loc + float2(- delta.x, + delta.y))) + kernel[2][1] * luma(tex2D(_Tex, loc + float2(0, + delta.y))) + kernel[2][2] * luma(tex2D(_Tex, loc + float2(+ delta.x, + delta.y)));
            }

            // can be rewritten to be more efficient by only computing the luma values once rather than for every kernel
            float kirsch(sampler2D _Tex, float2 loc, float2 delta) {
                float temp;
                
                temp = convolve(_MainTex, loc, delta,
                    float3x3(
                       +5.0, +5.0, +5.0,
                       -3.0, +0.0, -3.0,
                       -3.0, -3.0, -3.0 
                    )
                );
                temp = max(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       -3.0, +5.0, +5.0,
                       -3.0, +0.0, +5.0,
                       -3.0, -3.0, -3.0 
                    )
                ));
                temp = max(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       -3.0, -3.0, +5.0,
                       -3.0, +0.0, +5.0,
                       -3.0, -3.0, +5.0 
                    )
                ));
                temp = max(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       -3.0, -3.0, -3.0,
                       -3.0, +0.0, +5.0,
                       -3.0, +5.0, +5.0 
                    )
                ));
                temp = max(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       -3.0, -3.0, -3.0,
                       -3.0, +0.0, -3.0,
                       +5.0, +5.0, +5.0 
                    )
                ));
                temp = max(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       -3.0, -3.0, -3.0,
                       +5.0, +0.0, -3.0,
                       +5.0, +5.0, -3.0 
                    )
                ));
                temp = max(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       +5.0, -3.0, -3.0,
                       +5.0, +0.0, -3.0,
                       +5.0, -3.0, -3.0 
                    )
                ));
                temp = max(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       +5.0, +5.0, -3.0,
                       +5.0, +0.0, -3.0,
                       -3.0, -3.0, -3.0 
                    )
                ));
                return temp;
            }

	  		fixed4 frag (v2f_img i) : COLOR {
                float blend = 0.25;
	   			//fixed3 col = tex2D(_MainTex, i.uv).rgb;
                float edge = blend * kirsch(_MainTex, i.uv, _MainTex_TexelSize.xy) + (1.0 - blend) * float3(1.0, 1.0, 1.0) * luma(tex2D(_MainTex, i.uv));
				return fixed4(edge, edge, edge, 1.0);
	  		}
	  		ENDCG
	 	}
	}
}