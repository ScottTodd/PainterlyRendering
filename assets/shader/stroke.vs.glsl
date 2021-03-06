attribute vec3 strokeVertexNormal;
attribute vec2 strokeUV;

uniform sampler2D depthTexture;
uniform sampler2D objectTexture;

uniform float strokeSize;
uniform float specularMin;
uniform float specularFadeIn;
uniform float specularIntensity;
uniform float specularPower;
uniform int enableRotation;
uniform int useObjectTexture;
// uniform float lightGradientFactor;
uniform float curveFactor;
uniform float depthEpsilon;

uniform vec3 ambientLightColor;
#if MAX_DIR_LIGHTS > 0
uniform vec3 directionalLightDirection[MAX_DIR_LIGHTS];
uniform vec3 directionalLightColor[MAX_DIR_LIGHTS];
#endif

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


vec3 getColor()
{
	return (useObjectTexture == 1) ? texture2D(objectTexture, strokeUV).rgb : color;
}

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
void calcLight(vec3 mPosition, vec3 mNormal, out vec3 diffuseTotal, out vec3 specularTotal)
{
	vec3 dirToCamera =
		normalize(cameraPosition - mPosition);
	diffuseTotal =
		ambientLightColor;
	specularTotal =
		vec3(0, 0, 0);

	#if MAX_DIR_LIGHTS > 0
	for(int i = 0; i < MAX_DIR_LIGHTS; i++)
	{
		vec3 lightColor =
			directionalLightColor[i];
		vec3 dirToLight =
			-directionalLightDirection[i];
		vec3 phongDiffuse =
			lightColor * max(0.0, dot(dirToLight, mNormal));

		diffuseTotal += phongDiffuse;

		vec3 reflectedDir =
			normalize(reflect(-dirToLight, mNormal));
		float phongSpecular =
			pow(max(0.0, dot(reflectedDir, dirToCamera)), specularPower);

		specularTotal +=
			lightColor * phongSpecular;
	}
	#endif

	specularTotal *= specularIntensity;
}

/*
This could be faster if we only calculated intensities the whole way through...
*/
float calcLightAmount(vec3 mPosition, vec3 mNormal)
{
	vec3 diffuseTotal, specularTotal;
	calcLight(mPosition, mNormal, diffuseTotal, specularTotal);

	return colorAmount(diffuseTotal + specularTotal);//colorAmount(color * (diffuseTotal + specularTotal));
}

float length2(vec2 v)
{
	return dot(v, v);
}

float length2(vec3 v)
{
	return dot(v, v);
}

float square(float a)
{
	return a * a;
}


float getLightDifferential(
	vec3 oldMPos,
	vec3 rayDirAdjust,
	float lightAmount,
	vec3 oldMNormal)
{
	/*
	Approximate this area as a sphere.
	Discover the ray the camera fired to get here.
	Alter it by `dirAdjust`.
	Calculate the new sphere collision there.
	Then new normal and position can be calculated.
	Then calculate the new light at that normal and position,
	and return the difference.
	*/

	float curvatureRadius =
		// TODO: Attribute
		2.0;
	vec3 mCurveCenter =
		oldMPos - oldMNormal * curvatureRadius;

	vec3 oldRayDir =
		normalize(oldMPos - cameraPosition);

	vec3 newRayDir =
		oldRayDir + rayDirAdjust;

	/*
	Solve the ray equation.
	a * t^2 + b * t + c = 0
	*/
	float a =
		length2(newRayDir);
	float b =
		2.0 * dot(newRayDir, cameraPosition - mCurveCenter);
	float c =
		length2(cameraPosition - mCurveCenter) - square(curvatureRadius);
	float det =
		square(b) - 4.0 * a * c;
	// When curvature is high enough, we will surely hit the sphere
	// and can ignore the case where det would be negative.
	float sqrtDet =
		sqrt(det);
	float a2 =
		2.0 * a;
	float t =
		// We want the first `t`, so subtract sqrtDet.
		(-b - sqrtDet) / a2;

	vec3 newPos =
		cameraPosition + newRayDir * t;
	vec3 newNorm =
		normalize(newPos - mCurveCenter);

	return calcLightAmount(newPos, newNorm) - lightAmount;
}

float Pi =
	3.141592653589793238462643383279502884197169399375105820974944;

float cosEase(float x)
{
	return -0.5 * cos(Pi * x) + 0.5;
}

float shiftToRight(float x)
{
	return max(0.0, x * 2.0 - 1.0);
}

/*
Makes x stick closer to 1.
*/
float quadraticEase(float x)
{
	return 1.0 - square(1.0 - x);
}

float quarticEase(float x)
{
	return 1.0 - square(square(x - 1.0));
}

/*
Returned value has length in range [0..1].
*/
vec2 getGradient(
	vec3 mPosition,
	vec3 mvPosition,
	vec3 mNormal,
	vec3 mvNormal,
	float lightAmount)
{
	float lightGradientFactor =
		2.0;

	// Camera 'gradient'
	vec4 projectedNormal =
		normalize(projectionMatrix * vec4(mvNormal, 0));

	vec2 cameraGradient =
		-projectedNormal.xy;


	vec3 cameraRight =
		normalize(vec3(viewMatrix[0].x, viewMatrix[1].x, viewMatrix[2].x));
	vec3 cameraUp =
		normalize(vec3(viewMatrix[0].y, viewMatrix[1].y, viewMatrix[2].y));

	// Light gradient
	float epsilon =
		0.01;
	float dldx =
		getLightDifferential(mPosition, cameraRight * epsilon, lightAmount, mNormal);
	float dldy =
		getLightDifferential(mPosition, cameraUp * epsilon, lightAmount, mNormal);
	vec2 lightGradient =
		vec2(dldx, dldy);

	float cameraPart =
		length(cameraGradient);
	float lightPart =
		min(lightGradientFactor * length(lightGradient), square(1.0 - cameraPart));

	cameraGradient =
		normalize(cameraGradient);
	lightGradient =
		normalize(lightGradient);

	/*
	// Visualize the relative gradient contributions.
	strokeShadedColor =
		vec4(1, 0, 0, 1) * lightPart + vec4(0, 1, 0, 1) * cameraPart;
	*/

	return cameraPart * cameraGradient + lightPart * lightGradient;
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

float sampleDepth(vec4 glPosition)
{
	vec2 screenSpace =
		// Convert to normalized ([0, 1]^2) coordinates.
		(vec2(1, 1) + glPosition.xy / glPosition.w) / 2.0;
	return
		texture2D(depthTexture, screenSpace).z;
}

/*
1 when z is perfect.
0 when z is just barely good enough (strokeZDifference = strokeZEpsilon).
Negative when we shouldn't appear at all.
*/
float getZQuality(vec3 mvPosition, vec4 glPosition)
{
	float depthTextureZ =
		sampleDepth(glPosition);
	float strokeZDifference =
		abs(mvPosition.z - depthTextureZ);

	return 1.0 - (strokeZDifference / depthEpsilon);
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
		getZQuality(vec3(mvPosition), gl_Position);

	if (zQuality <= 0.0)
	{
		discardVertex();
		return;
	}

	vec3 mNormal =
		// Use 0.0 so there's no translation.
		normalize(vec3(modelMatrix * vec4(strokeVertexNormal, 0.0)));
	vec3 mvNormal =
		normalize(vec3(modelViewMatrix * vec4(strokeVertexNormal, 0.0)));

	vec3 diffuseTotal, specularTotal;
	calcLight(vec3(mPosition), mNormal, diffuseTotal, specularTotal);

	float specularTotalAmount =
		colorAmount(specularTotal);

	vec3 litColor =
		getColor() * (diffuseTotal + specularTotal);

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

	/*
	if (useObjectTexture == 1) {
		strokeShadedColor =
			vec4(litColor, alpha) + texture2D(objectTexture, strokeUV);
	} else {
		strokeShadedColor =
			vec4(litColor, alpha);
	}
	*/
	strokeShadedColor =
		vec4(litColor, alpha);

	float shrinkInDistance =
		1.0 / gl_Position.z;
	gl_PointSize =
		shrinkInDistance * strokeSize;

	vec2 gradient =
		getGradient(
			vec3(mPosition), vec3(mvPosition),
			mNormal, mvNormal,
			colorAmount(diffuseTotal + specularTotal));

	strokeOrientation =
		(enableRotation == 1) ?
			normalize(vec2(-gradient.y, gradient.x))
		:
			vec2(1.0, 0.0);

	if (length(strokeOrientation) < 0.99)
	{
		strokeShadedColor = vec4(1, 0, 0, 1);
		strokeOrientation = vec2(1, 0);
	}

	curveAmount =
		length(gradient) * curveFactor;
}
