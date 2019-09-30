Shader "Custom/Cell"
{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_RimValue ("Rim value", Range(0, 1)) = 0.5
		_Color ("Color", Color)=(1, 1, 1, 1)
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue"="Geometry" }
 
		CGPROGRAM
		//trying to find a way to write exclusively z-pass for shader to work with DoF
		ZWrite On
		ColorMask 0
		ENDCG

		CGPROGRAM
		#pragma surface surf Lambert alpha
 
		sampler2D _MainTex;
		fixed _RimValue;
 
		struct Input {
			float2 uv_MainTex;
			float3 viewDir;
			float3 worldNormal;
		};
 
		fixed4 _Color;
 
		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb * _Color;
 
			float3 normal = normalize(IN.worldNormal);
			float3 dir = normalize(IN.viewDir);
			float val = 1 - (abs(dot(dir, normal)));
			float rim = val * val * _RimValue;
			o.Alpha = c.a * rim;
		}
		ENDCG
	}
	FallBack "VertexLit"
}