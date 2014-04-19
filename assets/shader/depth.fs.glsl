#extension OES_texture_float : enable

varying vec4 mvPosition;

void main()
{
	gl_FragColor =
		vec4(mvPosition.xyz, 1);
}
