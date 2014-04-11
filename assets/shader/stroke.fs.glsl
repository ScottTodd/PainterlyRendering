uniform sampler2D strokeTexture;
varying vec4 strokeShadedColor;
varying float strokeOrientation;

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
	float textureAlpha =
		textureColor.r; // = g = b

	gl_FragColor = strokeShadedColor;
	gl_FragColor.a *= textureAlpha;
}
