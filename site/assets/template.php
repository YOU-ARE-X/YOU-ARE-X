<?php
global $artifact;
?>

<!DOCTYPE html>

<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>YOU ARE <?php echo strtoupper(ucfirst($artifact->attributes['name']));?></title>
	<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/normalize/5.0.0/normalize.css">
	<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Roboto:400,400i,700|Roboto+Mono">
	<link rel="stylesheet" type="text/css" href="assets/styles/style.css?">
	<script type="text/javascript" src="assets/scripts/3rd/jquery-1.6.2.min.js"></script>
	<script type="text/javascript" src="assets/scripts/3rd/three.min.js"></script>
	<script type="x-shader/x-vertex" id="standardVertexShader">
		varying vec2 vUv;
		
		void main()
		{
			vUv = uv;
			gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
		}
	</script>
	<script type="x-shader/x-fragment" id="gsFragmentShader">
		varying vec2 vUv;
		uniform float screenWidth;
		uniform float screenHeight;
		uniform sampler2D tSource;
		uniform float delta;
		uniform float feed;
		uniform float kill;
		uniform vec2 brush;
		
		vec2 texel = vec2(1.0/screenWidth, 1.0/screenHeight);
		float step_x = 1.0/screenWidth;
		float step_y = 1.0/screenHeight;
		
		void main()
		{
			if(brush.x < -5.0)
			{
				gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
				return;
			}
			
			vec2 uv = texture2D(tSource, vUv).rg;
			vec2 uv0 = texture2D(tSource, vUv+vec2(-step_x, 0.0)).rg;
			vec2 uv1 = texture2D(tSource, vUv+vec2(step_x, 0.0)).rg;
			vec2 uv2 = texture2D(tSource, vUv+vec2(0.0, -step_y)).rg;
			vec2 uv3 = texture2D(tSource, vUv+vec2(0.0, step_y)).rg;
			
			vec2 lapl = (uv0 + uv1 + uv2 + uv3 - 4.0*uv);//10485.76;
			float du = /*0.00002*/0.2097*lapl.r - uv.r*uv.g*uv.g + feed*(1.0 - uv.r);
			float dv = /*0.00001*/0.105*lapl.g + uv.r*uv.g*uv.g - (feed+kill)*uv.g;
			vec2 dst = uv + delta*vec2(du, dv);
			
			if(brush.x > 0.0)
			{
				vec2 diff = (vUv - brush)/texel;
				float dist = dot(diff, diff);
				if(dist < 5.0)
					dst.g = 0.9;
			}
			
			gl_FragColor = vec4(dst.r, dst.g, 0.0, 1.0);
		}
	</script>
	<script type="x-shader/x-fragment" id="screenFragmentShader">
		varying vec2 vUv;
		uniform float screenWidth;
		uniform float screenHeight;
		uniform sampler2D tSource;
		uniform float delta;
		uniform float feed;
		uniform float kill;
		uniform vec4 color1;
		uniform vec4 color2;
		uniform vec4 color3;
		uniform vec4 color4;
		uniform vec4 color5;
		
		vec2 texel = vec2(1.0/screenWidth, 1.0/screenHeight);
		
		void main()
		{
			float value = texture2D(tSource, vUv).g;
			//int step = int(floor(value));
			//float a = fract(value);
			float a;
			vec3 col;
			
			if(value <= color1.a)
				col = color1.rgb;
			if(value > color1.a && value <= color2.a)
			{
				a = (value - color1.a)/(color2.a - color1.a);
				col = mix(color1.rgb, color2.rgb, a);
			}
			if(value > color2.a && value <= color3.a)
			{
				a = (value - color2.a)/(color3.a - color2.a);
				col = mix(color2.rgb, color3.rgb, a);
			}
			if(value > color3.a && value <= color4.a)
			{
				a = (value - color3.a)/(color4.a - color3.a);
				col = mix(color3.rgb, color4.rgb, a);
			}
			if(value > color4.a && value <= color5.a)
			{
				a = (value - color4.a)/(color5.a - color4.a);
				col = mix(color4.rgb, color5.rgb, a);
			}
			if(value > color5.a)
				col = color5.rgb;
			
			gl_FragColor = vec4(col.r, col.g, col.b, 1.0);
		}
	</script>
	<script type="text/javascript" src="assets/scripts/reaction-diffusion.js"></script>
	<script type="text/javascript" src="assets/scripts/you are.js"></script>
</head>

<body>
	<canvas id="myCanvas"></canvas>
	
	<div id="header">
		<span id="bannerText"></span>
	</div>

	<div id="title">
		<h1 class="title"><?php echo $artifact->attributes['title'];?></h1>
		<?php if ($artifact->attributes['name'] != 'Index') echo '<a id="home-link" href="index">─ back home</a>'; ?>
	</div>

	<div id="body">
		<div id="body-content">
			<?php echo $artifact->attributes['content'];?>
		</div>
	</div>

	<div id="footer">
		<span>Powered by <a href="https://v-os.ca/purity">Purity</a>.</span>
	</div>
<script src="assets/requestscript.js"></script>
</body>
</html>