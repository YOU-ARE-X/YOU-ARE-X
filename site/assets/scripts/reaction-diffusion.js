/* 
* Gray-Scott
*
* A solver of the Gray-Scott model of reaction diffusion.
*
* ©2012 pmneila.
* p.mneila at upm.es
*/

// Canvas.
var canvas;
var canvasQ;
var canvasWidth;
var canvasHeight;

var mMouseX, mMouseY;
var mMouseDown = false;

var mRenderer;
var mScene;
var mCamera;
var mUniforms;
var mColors;
var mColorsNeedUpdate = true;
var mLastTime = 0;

var mTexture1, mTexture2;
var mGSMaterial, mScreenMaterial;
var mScreenQuad;

var mToggled = false;

var mMinusOnes = new THREE.Vector2(-1, -1);

// Configuration.
var feed = generateRandomNumber(0.037, 0.04);
var kill = generateRandomNumber(0.06, 0.065);

function init()
{
	canvasQ = $('#myCanvas');
	canvas = canvasQ.get(0);
	
	mRenderer = new THREE.WebGLRenderer({canvas: canvas, preserveDrawingBuffer: true});

	mScene = new THREE.Scene();
	mCamera = new THREE.OrthographicCamera(-0.5, 0.5, 0.5, -0.5, -10000, 10000);
	mCamera.position.z = 100;
	mScene.add(mCamera);
	
	mUniforms = {
		screenWidth: {type: "f", value: undefined},
		screenHeight: {type: "f", value: undefined},
		tSource: {type: "t", value: undefined},
		delta: {type: "f", value: 1.0},
		feed: {type: "f", value: feed},
		kill: {type: "f", value: kill},
		brush: {type: "v2", value: new THREE.Vector2(-10, -10)},
		color1: {type: "v4", value: new THREE.Vector4(0.95, 0.95, 0.95, 0.2)},
		color2: {type: "v4", value: new THREE.Vector4(0.95, 0.95, 0.95, 0.2)},
		color3: {type: "v4", value: new THREE.Vector4(0.95, 0.95, 0.95, 0.25)},
		color4: {type: "v4", value: new THREE.Vector4(0.95, 0.95, 0.95, 0.2)},
		color5: {type: "v4", value: new THREE.Vector4(0.95, 0.95, 0.95, 0.2)}
	};
	mColors = [mUniforms.color1, mUniforms.color2, mUniforms.color3, mUniforms.color4, mUniforms.color5];
	
	mGSMaterial = new THREE.ShaderMaterial({
			uniforms: mUniforms,
			vertexShader: document.getElementById('standardVertexShader').textContent,
			fragmentShader: document.getElementById('gsFragmentShader').textContent,
		});
	mScreenMaterial = new THREE.ShaderMaterial({
				uniforms: mUniforms,
				vertexShader: document.getElementById('standardVertexShader').textContent,
				fragmentShader: document.getElementById('screenFragmentShader').textContent,
			});
	
	var plane = new THREE.PlaneGeometry(1.0, 1.0);
	mScreenQuad = new THREE.Mesh(plane, mScreenMaterial);
	mScene.add(mScreenQuad);
	
	mColorsNeedUpdate = true;
	
	resize();
	
	render(0);
	mUniforms.brush.value = new THREE.Vector2(0.5, 0.5);
	mLastTime = new Date().getTime();
	requestAnimationFrame(render);
}

function resize()
{
	// Set the new shape of canvas.
	canvasQ.width(document.body.clientWidth);
	canvasQ.height(document.body.clientHeight);
	
	// Get the real size of canvas.
	canvasWidth = canvasQ.width();
	canvasHeight = canvasQ.height();
	
	mRenderer.setSize(canvasWidth, canvasHeight);
	
	// TODO: Possible memory leak?
	mTexture1 = new THREE.WebGLRenderTarget(canvasWidth/2, canvasHeight/2,
						{minFilter: THREE.LinearFilter,
						 magFilter: THREE.LinearFilter,
						 format: THREE.RGBAFormat,
						 type: THREE.FloatType});
	mTexture2 = new THREE.WebGLRenderTarget(canvasWidth/2, canvasHeight/2,
						{minFilter: THREE.LinearFilter,
						 magFilter: THREE.LinearFilter,
						 format: THREE.RGBAFormat,
						 type: THREE.FloatType});
	mUniforms.screenWidth.value = canvasWidth/2;
	mUniforms.screenHeight.value = canvasHeight/2;
}

function render(time)
{
	var dt = (time - mLastTime)/20.0;
	if(dt > 0.8 || dt<=0)
		dt = 0.8;
	mLastTime = time;
	
	mScreenQuad.material = mGSMaterial;
	mUniforms.delta.value = dt;
	mUniforms.feed.value = feed;
	mUniforms.kill.value = kill;
	
	for(var i=0; i<8; ++i)
	{
		if(!mToggled)
		{
			mUniforms.tSource.value = mTexture1;
			mRenderer.render(mScene, mCamera, mTexture2, true);
			mUniforms.tSource.value = mTexture2;
		}
		else
		{
			mUniforms.tSource.value = mTexture2;
			mRenderer.render(mScene, mCamera, mTexture1, true);
			mUniforms.tSource.value = mTexture1;
		}
		
		mToggled = !mToggled;
		mUniforms.brush.value = mMinusOnes;
	}
	
	if(mColorsNeedUpdate)
		updateUniformsColors();
	
	mScreenQuad.material = mScreenMaterial;
	mRenderer.render(mScene, mCamera);
	
	requestAnimationFrame(render);
}

function updateUniformsColors()
{
	var values = [[1.0, 1.0, 1.0, 1.0],[0.8, 0.8, 0.8, 1.0]];
	for(var i=0; i<values.length; i++)
	{
		var v = values[i];
		mColors[i].value = new THREE.Vector4(v[0], v[1], v[2], v[3]);
	}
	
	mColorsNeedUpdate = false;
}

function onMouseMove(e)
{
	var ev = e ? e : window.event;
	
	mMouseX = ev.pageX - canvasQ.offset().left; // these offsets work with
	mMouseY = ev.pageY - canvasQ.offset().top; // scrolled documents too
	
	mUniforms.brush.value = new THREE.Vector2(mMouseX/canvasWidth, 1-mMouseY/canvasHeight);
}

function clean()
{
	mUniforms.brush.value = new THREE.Vector2(-10, -10);
}

function worldToForm()
{
	//document.ex.sldReplenishment.value = feed * 1000;
	$("#sld_replenishment").slider("value", feed);
	$("#sld_diminishment").slider("value", kill);
}

function generateRandomNumber(min, max)
{
	return Math.random() * (max - min) + min;
}

window.addEventListener("resize", resize);
window.addEventListener("mousemove", onMouseMove);