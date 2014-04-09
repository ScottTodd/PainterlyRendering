attribute vec3 strokeVertexNormal;

/*
Three.js also gives us these:
position
color
modelViewMatrix
projectionMatrix
*/

varying vec4 strokeShadedColor;

void main()
{
	float phongDiffuse =
		1.0; //dot(dirToLight, strokeVertexNormal);
	float phongSpecular =
		0.0; //specular * pow(reflDir * dirToCamera, shininess);
	vec3 lightColor =
		vec3(1, 1, 1);
	vec3 phongLight =
		lightColor * (phongDiffuse + phongSpecular);

	strokeShadedColor =
		vec4(color * phongLight, 1.0);

	vec4 mvPosition =
		modelViewMatrix * vec4(position, 1.0);

	gl_Position =
		projectionMatrix * mvPosition;

	vec4 mvNormal =
		modelViewMatrix * vec4(strokeVertexNormal, 0.0);
	vec4 projectedNormal =
		normalize(projectionMatrix * mvNormal);
	float cosTowardsCamera =
		- projectedNormal.z;

	float shrinkInDistance =
		1.0 / gl_Position.z;

	// This also culls backfacing strokes (gl_PointSize will be negative)
	gl_PointSize =
		shrinkInDistance * cosTowardsCamera * 160.0;
}

