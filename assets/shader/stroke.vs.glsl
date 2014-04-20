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
varying vec4 mvPosition;

/*
How much we weight a color's importance.
This doesn't necessarily have to equally value r, g, and b.
*/
float colorAmount(vec3 color)
{
	return color.r + color.g + color.b;
}

/*
How much light am I recieving if I face in the direction `mvNormal`?
*/
vec3 calcLight(vec3 mvNormal, out float specularTotalAmount)
{
	specularTotalAmount = 0.0;

	const vec3 dirToCamera =
		// TODO: calculate
		vec3(0, 0, -1);
	const float specularAmount =
		4.0;
	const float specularPow =
		8.0;

	vec3 lightTotal = ambientLightColor;

	for(int i = 0; i < MAX_DIR_LIGHTS; i++)
	{
		vec3 dirToLight =
			-directionalLightDirection[i];
		float phongDiffuse =
			max(0.0, dot(dirToLight, vec3(mvNormal)));
		vec3 reflectedDir =
			normalize(reflect(dirToLight, vec3(mvNormal)));
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
Calculates stroke orientation.
Strokes on the edge (where the normal is perpendicular to the camera) should follow the border.
Otherwise, strokes should circle around light.
*/
vec2 getOrientation(vec4 mvNormal, vec3 lightTotal)
{
	vec4 projectedNormal =
		normalize(projectionMatrix * mvNormal);

	vec2 relToCamera =
		vec2(-projectedNormal.y, projectedNormal.x);

	float epsilon =
		0.01;

	vec3 dxNormal =
		vec3(mvNormal) + vec3(epsilon, 0, 0);
	vec3 dyNormal =
		vec3(mvNormal) + vec3(0, epsilon, 0);

	// Estimate the gradient here by altering the normal.
	// (If the object is concave this will be the opposite of the correct answer...)
	float junk;
	float dx =
		colorAmount(calcLight(dxNormal, junk)) - colorAmount(lightTotal);
	float dy =
		colorAmount(calcLight(dyNormal, junk)) - colorAmount(lightTotal);

	vec2 relToLight =
		// Perpendicular to gradient
		vec2(-dy, dx);

	float camPart =
		projectedNormal.z;
	float lightPart =
		1.0;
	return normalize(camPart * relToCamera + lightPart * relToLight);
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

void main()
{
	mvPosition =
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

	vec4 mvNormal =
		// TODO: lighting normals don't work with quaternions; use normalMatrix ?
		// Use 0.0 so there's no translation.
		modelViewMatrix * vec4(strokeVertexNormal, 0.0);

	float specularTotalAmount;
	vec3 lightTotal =
		calcLight(vec3(mvNormal), specularTotalAmount);

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

	strokeShadedColor =
		vec4(color * lightTotal, specularAmountToAlpha);

	// 'Marginal' strokes just coming around the edge of an object are partly transparent.
	strokeShadedColor.a *= min(zQuality, 1.0);

	float shrinkInDistance =
		1.0 / gl_Position.z;
	gl_PointSize =
		shrinkInDistance * strokeSize;

	strokeOrientation =
		getOrientation(mvNormal, lightTotal);
}
