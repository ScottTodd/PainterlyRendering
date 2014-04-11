attribute vec3 strokeVertexNormal;

uniform vec3 ambientLightColor;
uniform vec3 directionalLightDirection[MAX_DIR_LIGHTS];
uniform vec3 directionalLightColor[MAX_DIR_LIGHTS];

/*
Three.js also gives us these:
position
color
modelViewMatrix
projectionMatrix
*/

varying vec4 strokeShadedColor;
varying float strokeOrientation;

const float Pi =
	3.1415926535897932384626433832795;

void main()
{
	vec3 lightTotal = ambientLightColor;
	for(int i = 0; i < MAX_DIR_LIGHTS; i++) {
		vec3 dirToLight =
			-directionalLightDirection[i];
		float phongDiffuse =
			max(0.0, dot(dirToLight, strokeVertexNormal));
			// 1.0;
		float phongSpecular =
			0.0; //specular * pow(reflDir * dirToCamera, shininess);
		vec3 lightColor =
			directionalLightColor[i];
			// vec3(1, 1, 1);
		vec3 phongLight =
			lightColor * (phongDiffuse + phongSpecular);

		lightTotal += phongLight;
	}
	lightTotal = clamp(lightTotal, 0.0, 1.0);

	strokeShadedColor =
		vec4(color * lightTotal, 1.0);

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

	strokeOrientation =
		atan(projectedNormal.y, projectedNormal.x);

	float shrinkInDistance =
		1.0 / gl_Position.z;

	// This also culls backfacing strokes (gl_PointSize will be negative)
	gl_PointSize =
		shrinkInDistance * cosTowardsCamera * 160.0;
}

