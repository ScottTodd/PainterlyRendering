#extension OES_texture_float : enable

uniform sampler2D strokeTexture;

uniform sampler2D depthTexture;

varying vec4 strokeShadedColor;
varying float strokeOrientation;
varying vec4 mvPosition;

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
	vec2 textureCoordinate =
		rotate2D(gl_PointCoord, vec2(0.5, 0.5), strokeOrientation);
	vec4 textureColor =
		texture2D(strokeTexture, textureCoordinate);
	gl_FragColor = strokeShadedColor;

	float textureAlpha =
		textureColor.r; // = g = b
	gl_FragColor.a *= textureAlpha;

	// TODO: Remove hardcoded screen dimensions from this calculation
	vec2 fragmentTextureCoordinate =
		vec2(gl_FragCoord.x/400.0, gl_FragCoord.y/300.0);
	float depthTextureZ =
		texture2D(depthTexture, fragmentTextureCoordinate).z;
	float zDifference =
		abs(mvPosition.z - depthTextureZ);
	if (zDifference > 1.0) {
		gl_FragColor.a = 0.0;
	}
}
