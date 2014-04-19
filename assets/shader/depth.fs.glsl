#extension OES_texture_float : enable

varying vec4 mvPosition;

void main()
{
	gl_FragColor =
		vec4(mvPosition.x, mvPosition.y, mvPosition.z, 1);
}
