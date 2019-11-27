Shader "KirschRGB" {
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

            // parameters set by script
            float blend;
            int usetanh;
            float slope;   
            
            float3 convolve(sampler2D _Tex, float2 loc, float2 delta, float3x3 kernel) {
                return kernel[0][0] * tex2D(_Tex, loc + float2(- delta.x, - delta.y)) + kernel[0][1] * tex2D(_Tex, loc + float2(0, - delta.y)) + kernel[0][2] * tex2D(_Tex, loc + float2(+ delta.x, - delta.y)) +
                       kernel[1][0] * tex2D(_Tex, loc + float2(- delta.x,         0)) + kernel[1][1] * tex2D(_Tex, loc + float2(0,         0)) + kernel[1][2] * tex2D(_Tex, loc + float2(+ delta.x,         0)) +
                       kernel[2][0] * tex2D(_Tex, loc + float2(- delta.x, + delta.y)) + kernel[2][1] * tex2D(_Tex, loc + float2(0, + delta.y)) + kernel[2][2] * tex2D(_Tex, loc + float2(+ delta.x, + delta.y));
            }

            float3 max3(float3 a, float3 b) {
                return float3(
                    max(a.r, b.r),
                    max(a.g, b.g),
                    max(a.b, b.b)
                );
            }

            // can be rewritten to be more efficient by only computing the luma values once rather than for every kernel
            float3 kirsch(sampler2D _Tex, float2 loc, float2 delta) {
                float3 temp;
                
                temp = convolve(_MainTex, loc, delta,
                    float3x3(
                       +5.0, +5.0, +5.0,
                       -3.0, +0.0, -3.0,
                       -3.0, -3.0, -3.0 
                    )
                );
                temp = max3(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       -3.0, +5.0, +5.0,
                       -3.0, +0.0, +5.0,
                       -3.0, -3.0, -3.0 
                    )
                ));
                temp = max3(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       -3.0, -3.0, +5.0,
                       -3.0, +0.0, +5.0,
                       -3.0, -3.0, +5.0 
                    )
                ));
                temp = max3(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       -3.0, -3.0, -3.0,
                       -3.0, +0.0, +5.0,
                       -3.0, +5.0, +5.0 
                    )
                ));
                temp = max3(temp, convolve(_MainTex, loc, delta,
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
                temp = max3(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       +5.0, -3.0, -3.0,
                       +5.0, +0.0, -3.0,
                       +5.0, -3.0, -3.0 
                    )
                ));
                temp = max3(temp, convolve(_MainTex, loc, delta,
                    float3x3(
                       +5.0, +5.0, -3.0,
                       +5.0, +0.0, -3.0,
                       -3.0, -3.0, -3.0 
                    )
                ));
                return temp;
            }

            float tanhNormalized(float x) {
                return 0.5 * (tanh(2.0 * x - 1.0) + 1.0);
            }

            float tanhNormalizedSloped(float x, float s) {
                return 0.5 * (tanh(2.0 * s * (x - 0.5)) + 1.0);
            }

            float3 tanhNormalizedSloped3(float3 x, float s) {
                return float3(
                    tanhNormalizedSloped(x.r, s), 
                    tanhNormalizedSloped(x.g, s), 
                    tanhNormalizedSloped(x.b, s)
                 );
            }

	  		fixed4 frag (v2f_img i) : COLOR {
                float3 edge = blend * kirsch(_MainTex, i.uv, _MainTex_TexelSize.xy) + (1.0 - blend) * tex2D(_MainTex, i.uv);
                if(usetanh) {
                    edge = tanhNormalizedSloped3(edge, slope);
                }
				return fixed4(edge, 1.0);
	  		}
	  		ENDCG
	 	}
	}
}