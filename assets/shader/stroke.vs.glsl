attribute vec3 strokeColor;

varying vec3 strokePosition;
varying vec4 strokeShadedColor;

void main()
{
	strokePosition =
		position;
	strokeShadedColor =
		// TODO: Calculate from lighting
		vec4(strokeColor, 1);

	vec4 mvPosition =
		modelViewMatrix * vec4(position, 1);

	gl_PointSize =
		20.0;

	gl_Position =
		projectionMatrix * mvPosition;
}

