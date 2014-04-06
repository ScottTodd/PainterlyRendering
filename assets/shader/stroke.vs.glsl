attribute vec3 strokeColor;
attribute vec3 strokeVertexNormal;

varying vec3 strokePosition;
varying vec4 strokeShadedColor;
varying vec3 strokeNormal;

void main()
{
	strokePosition =
		position;
	strokeShadedColor =
		// TODO: Calculate from lighting
		vec4(strokeColor, 1.0);

	vec4 mvNormal =
		modelViewMatrix * vec4(strokeVertexNormal, 0.0);
	strokeNormal =
		(projectionMatrix * mvNormal).xyz;

	vec4 mvPosition =
		modelViewMatrix * vec4(position, 1.0);

	gl_PointSize =
		20.0;

	gl_Position =
		projectionMatrix * mvPosition;
}

