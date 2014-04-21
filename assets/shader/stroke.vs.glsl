attribute vec3 strokeVertexNormal;

uniform float strokeSize;

uniform sampler2D depthTexture;

uniform vec3 ambientLightColor;
uniform vec3 directionalLightDirection[MAX_DIR_LIGHTS];
uniform vec3 directionalLightColor[MAX_DIR_LIGHTS];
uniform float specularMin;
uniform float specularFadeIn;

/*
Three.js also gives us these:
position
color
modelViewMatrix
projectionMatrix
*/

varying vec4 strokeShadedColor;
varying vec2 strokeOrientation;
varying float curveAmount;

/*
How much we weight a color's importance.
This doesn't necessarily have to equally value r, g, and b.
*/
float colorAmount(vec3 color)
{
	return color.r + color.g + color.b;
}

/*
How much light am I recieving if I face in the direction `mNormal`?
*/
vec3 calcLight(vec3 mPosition, vec3 mNormal, out float specularTotalAmount)
{
	specularTotalAmount = 0.0;

	vec3 dirToCamera =
		normalize(cameraPosition - mPosition);
	const float specularAmount =
		// TODO: uniform
		4.0;
	const float specularPow =
		// TODO: uniform
		8.0;

	vec3 lightTotal = ambientLightColor;

	for(int i = 0; i < MAX_DIR_LIGHTS; i++)
	{
		vec3 dirToLight =
			-directionalLightDirection[i];
		float phongDiffuse =
			max(0.0, dot(dirToLight, vec3(mNormal)));
		vec3 reflectedDir =
			normalize(reflect(-dirToLight, vec3(mNormal)));
		float phongSpecular =
			specularAmount * pow(max(0.0, dot(reflectedDir, dirToCamera)), specularPow);
		vec3 lightColor =
			directionalLightColor[i];

		specularTotalAmount +=
			colorAmount(lightColor * phongSpecular);

		vec3 phongLight =
			lightColor * (phongDiffuse + phongSpecular);
		lightTotal += phongLight;
	}

	return lightTotal;
}

/*
This could be faster if we only calculated intensities the whole way through...
*/
float calcLightAmount(vec3 mPosition, vec3 mNormal)
{
	float junk;
	vec3 light =
		calcLight(mPosition, mNormal, junk);

	return colorAmount(light);
}

vec2 getGradient(vec3 mPosition, vec3 mNormal, vec3 mvNormal, float lightAmount)
{
	// Camera 'gradient'
	vec4 projectedNormal =
		normalize(projectionMatrix * vec4(mvNormal, 0));

	vec2 cameraGradient =
		projectedNormal.xy;

	// Light gradient
	float epsilon =
		0.01;
	vec3 dxNormal =
		mNormal + vec3(epsilon, 0, 0);
	vec3 dyNormal =
		mNormal + vec3(0, epsilon, 0);
	// Estimate the gradient here by altering the normal.
	// (If the object is concave this will be the opposite of the correct answer...)
	float dx =
		calcLightAmount(mPosition, dxNormal) - lightAmount;
	float dy =
		calcLightAmount(mPosition, dyNormal) - lightAmount;
	vec2 lightGradient =
		vec2(dx, dy);

	float camPart =
		projectedNormal.z;
	float lightPart =
		1.0;

	return camPart * cameraGradient + lightPart * lightGradient;
}

/*
Ensures that this vertex is not rendered.
*/
void discardVertex()
{
	gl_PointSize =
		0.0;
	gl_Position =
		vec4(-100, -100, -100, 1);
}

/*
1 when z is perfect.
0 when z is just barely good enough (strokeZDifference = strokeZEpsilon).
Negative when we shouldn't appear at all.
*/
float getZQuality(vec4 mvPosition, vec4 glPosition)
{
	vec2 screenSpace =
		// Convert to normalized ([0, 1]^2) coordinates.
		(vec2(1, 1) + glPosition.xy / glPosition.w) / 2.0;
	float depthTextureZ =
		texture2D(depthTexture, screenSpace).z;
	float strokeZDifference =
		abs(mvPosition.z - depthTextureZ);
	const float strokeZEpsilon =
		// TODO: This should vary by object size
		1.0;

	return 1.0 - (strokeZDifference / strokeZEpsilon);
}

float manhattanLength(vec2 v)
{
	return abs(v.x) + abs(v.y);
}


void main()
{
	vec4 mPosition =
		modelMatrix * vec4(position, 1.0);
	vec4 mvPosition =
		modelViewMatrix * vec4(position, 1.0);
	gl_Position =
		projectionMatrix * mvPosition;
	float zQuality =
		getZQuality(mvPosition, gl_Position);

	if (zQuality <= 0.0)
	{
		discardVertex();
		return;
	}

	vec3 mNormal =
		vec3(modelMatrix * vec4(strokeVertexNormal, 0.0));
	vec3 mvNormal =
		// TODO: lighting normals don't work with quaternions; use normalMatrix ?
		// Use 0.0 so there's no translation.
		vec3(modelViewMatrix * vec4(strokeVertexNormal, 0.0));

	float specularTotalAmount;
	vec3 lightTotal =
		calcLight(vec3(mPosition), mNormal, specularTotalAmount);

	if (specularTotalAmount < specularMin)
	{
		discardVertex();
		return;
	}

	float specularAmountToAlpha =
		(specularFadeIn == 0.0) ?
			1.0
		:
			min(1.0, (specularTotalAmount - specularMin) / specularFadeIn);

	float zQualityAlpha =
		// 'Marginal' strokes just coming around the edge of an object are partly transparent.
		min(zQuality, 1.0);

	float alpha =
		specularAmountToAlpha * zQualityAlpha;

	strokeShadedColor =
		vec4(color * lightTotal, alpha);


	float shrinkInDistance =
		1.0 / gl_Position.z;
	gl_PointSize =
		shrinkInDistance * strokeSize;

	vec2 gradient =
		getGradient(vec3(mPosition), mNormal, mvNormal, colorAmount(lightTotal));

	strokeOrientation =
		normalize(vec2(-gradient.y, gradient.x));

	float curveFactor =
		// TODO: uniform
		2.0;
	// This should be in [0..1] or the stroke will be clipped.
	curveAmount =
		manhattanLength(gradient) * curveFactor;
}
