Shader "ReactionDiffusion" {
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
            
            float4 _MainTex_TexelSize;

	  		uniform sampler2D _MainTex;
            uniform sampler2D _SourceTex; 

            float laplace(sampler2D _Tex, float2 loc) {
                float2 delta = _MainTex_TexelSize.xy;
                return 0.05 * tex2D(_Tex, loc + float2(- delta.x, - delta.y)) + 0.20 * tex2D(_Tex, loc + float2(0, - delta.y)) + 0.05 * tex2D(_Tex, loc + float2(+ delta.x, - delta.y)) +
                       0.20 * tex2D(_Tex, loc + float2(- delta.x,         0)) - 1.00 * tex2D(_Tex, loc + float2(0,         0)) + 0.20 * tex2D(_Tex, loc + float2(+ delta.x,         0)) +
                       0.05 * tex2D(_Tex, loc + float2(- delta.x, + delta.y)) + 0.20 * tex2D(_Tex, loc + float2(0, + delta.y)) + 0.05 * tex2D(_Tex, loc + float2(+ delta.x, + delta.y));
            }

            fixed4 compose(float4 source, float4 accum) {
                return source + accum;
            }

	  		fixed4 frag(v2f_img i) : COLOR {
			    //return tex2D(_SourceTex, i.uv);
                return compose(tex2D(_SourceTex, i.uv), pow(laplace(_MainTex, i.uv), 2.0));
	  		}
	  		ENDCG
	 	}
	}
}