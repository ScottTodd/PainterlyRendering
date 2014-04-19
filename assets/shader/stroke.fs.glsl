#extension OES_texture_float : enable

uniform sampler2D strokeTexture;

uniform sampler2D depthTexture;

varying vec4 strokeShadedColor;
varying vec2 strokeOrientation;
varying vec4 mvPosition;
varying float strokeZDifference;

vec2 rotate2D(vec2 point, vec2 origin, vec2 orientation)
{
	// Orientation was normalized for xyzw, compute hypotenuse for just xy
	float h =
	   sqrt(orientation.x * orientation.x + orientation.y * orientation.y);
	vec2 rel =
		point - origin;
	float kos =
		orientation.x / h;
	float zin =
		orientation.y / h;
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
	float fragmentZDifference =
		abs(mvPosition.z - depthTextureZ);

	// Stroke z difference:
	//   - causes flickering around the edges
	//   - lets strokes extend past the silhouette.

	// Fragment z difference:
	//   - has no flickering
	//   - does not let strokes extend past the silhouette

	// if (fragmentZDifference > 1.0 && strokeZDifference > 1.0) {
	if (fragmentZDifference > 1.0) {
		gl_FragColor.a = 0.0;
	}
}
