#extension OES_texture_float : enable

uniform sampler2D strokeTexture;

varying vec4 strokeShadedColor;
varying vec2 strokeOrientation;
varying vec4 mvPosition;

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
}
