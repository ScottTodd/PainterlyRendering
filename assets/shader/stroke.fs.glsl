uniform float bright;

varying vec3 vPosition;
varying vec4 strokeShadedColor;
varying vec3 strokeNormal;

// Should rotate points in [0, 1]^2 around (0.5, 0.5)
// varying
const mat3 rotationMatrix = mat3(1, 0, 0, 0, 1, 0, 0, 0, 1);

uniform sampler2D strokeTexture;

const float Pi =
	3.1415926535897932384626433832795;

const float CheckerSize = 0.2;

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
	// Cull back-facing strokes
	vec3 intoScreen = vec3(0, 0, -1);
	float cosTheta = dot(intoScreen, strokeNormal);
	if (cosTheta < 0.0) {
		discard;
		return;
	}

	float orientation =
		Pi / 3.0;

	vec2 textureCoordinate =
		rotate2D(gl_PointCoord, vec2(0.5, 0.5), orientation);

	vec4 textureColor =
		texture2D(strokeTexture, gl_PointCoord);
	float textureAlpha =
		textureColor.r; // = g = b

	// Interesting shaded effect, maybe we should try other mixing here?
	// gl_FragColor += strokeShadedColor * textureAlpha;

	if (textureAlpha > 0.01) {
		gl_FragColor =
			strokeShadedColor;
		gl_FragColor.a = textureAlpha;
	} else {
		discard;
	}
}

