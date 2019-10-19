Shader "MeltVR" {
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
                
                float2 dist = 0.2 * float2(
                    cnoise(float3(10.0 * (coord), _Time.y * 0.5)), 
                    cnoise(float3(10.0 * (coord +  float2(1.0, 1.0)), _Time.y * 0.5))
                );

                return coord 
                + 2.5 * unity_DeltaTime.z * float2(
                    cnoise(float3(2.0 * (coord + dist), _Time.y * 0.2)), 
                    cnoise(float3(2.0 * (coord + dist +  float2(1.0, 1.0)), _Time.y * 0.2))
                );
            }

	  		fixed4 frag(v2f_img i) : COLOR {
			    return exp(- unity_DeltaTime.z * 8.0) * fixed4(tex2D(_MainTex, remap(i.uv)).rgba);
	  		}
	  		ENDCG
	 	}

        Pass {
            // copy camera image over current accumulation buffer with alpha

            // TODO: add sky texture or color input
            
            // original, liquid inside object, preserves background alpha
            // Blend SrcAlpha OneMinusSrcAlpha

            // properly working, liquid trailing off object, does not preserve background alpha
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