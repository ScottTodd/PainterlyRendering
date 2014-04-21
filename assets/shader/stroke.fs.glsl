#extension OES_texture_float : enable

uniform sampler2D strokeTexture;

uniform sampler2D depthTexture;

varying vec4 strokeShadedColor;
varying vec2 strokeOrientation;
varying float curveAmount;

vec2 rotate2D(vec2 point, vec2 origin, vec2 orientation)
{
	vec2 rel =
		point - origin;
	float kos =
		orientation.x;
	float zin =
		orientation.y;
	vec2 rotated =
		vec2(kos * rel.x - zin * rel.y, zin * rel.x + kos * rel.y);

	return rotated + origin;
}

float square(float a)
{
	return a * a;
}

vec4 clippedSample(sampler2D texture, vec2 sampleAt)
{
	if (sampleAt.x <= 0.0 || sampleAt.x >= 1.0 || sampleAt.y <= 0.0 || sampleAt.y >= 1.0)
		return vec4(0, 0, 0, 0);
	else
		return texture2D(texture, sampleAt);
}

/*
Leaves middle alone. Drops ends by `curveAmount` like a parabola.
*/
vec2 distort(vec2 textureCoordinate)
{
	float bottom =
		-curveAmount;

	float x =
		textureCoordinate.x;

	float y =
		// For some reason, this leads to sampling artifacts.
		// curveAmount * square(x - 0.5);
		curveAmount * (square(x) - x + 0.25);

	return vec2(x, textureCoordinate.y - y);
}


void main()
{
	gl_FragColor = strokeShadedColor;

	vec2 rotated =
		rotate2D(gl_PointCoord, vec2(0.5, 0.5), strokeOrientation);
	vec2 distorted =
		distort(rotated);
	vec4 textureColor =
		clippedSample(strokeTexture, distorted);
	float textureAlpha =
		textureColor.r; // = g = b
	gl_FragColor.a *= textureAlpha;
}
