varying vec4 mvPosition;

/*
Three.js gives us these:
position
color
modelViewMatrix
projectionMatrix
*/

void main()
{
	mvPosition =
		modelViewMatrix * vec4(position, 1.0);

	gl_Position =
		projectionMatrix * mvPosition;
}
