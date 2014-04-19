uniform sampler2D strokeTexture;
uniform sampler2D depthTexture;
uniform float minimumZ;
uniform float maximumZ;

varying vec4 strokeShadedColor;
varying float strokeOrientation;
varying vec4 mvPosition;

float remap(float outputMin, float outputMax,
			float inputMin,  float inputMax, float inputValue)
{
	float inputRange  = inputMax  - inputMin;
	float outputRange = outputMax - outputMin;

	float inputScaledValue  = (inputValue - inputMin) / inputRange;
	float outputScaledValue = inputScaledValue * outputRange + outputMin;

	return outputScaledValue;
}

vec2 rotate2D(vec2 point, vec2 origin, float angle)
{
	vec2 rel =
		point - origin;
	// For speed, we could calculate these in vertex shader.
	float kos =
		cos(angle);
	float zin =
		sin(angle);
	vec2 rotated =
		vec2(kos * rel.x - zin * rel.y, zin * rel.x + kos * rel.y);

	return rotated + origin;
}

void main()
{
	float remappedZ = remap(0.0, 1.0, minimumZ, maximumZ, mvPosition.z);

	vec2 fragmentTextureCoordinate =
		vec2(gl_FragCoord.x/400.0, gl_FragCoord.y/300.0);
	float depthTextureZ = texture2D(depthTexture, fragmentTextureCoordinate).z;

	float zDifference = abs(remappedZ - depthTextureZ);

	if (zDifference < 0.1) {
		vec2 textureCoordinate =
			rotate2D(gl_PointCoord, vec2(0.5, 0.5), strokeOrientation);
		vec4 textureColor =
			texture2D(strokeTexture, textureCoordinate);
		float textureAlpha =
			textureColor.r; // = g = b

		gl_FragColor = strokeShadedColor;
		gl_FragColor.a *= textureAlpha;
	} else {
		discard;
	}
}
