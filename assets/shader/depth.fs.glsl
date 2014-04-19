// #extension OES_texture_float : enable

varying vec4 mvPosition;

uniform float minimumZ;
uniform float maximumZ;

float remap(float outputMin, float outputMax,
			float inputMin,  float inputMax, float inputValue)
{
	float inputRange  = inputMax  - inputMin;
	float outputRange = outputMax - outputMin;

	float inputScaledValue  = (inputValue - inputMin) / inputRange;
	float outputScaledValue = inputScaledValue * outputRange + outputMin;

	return outputScaledValue;
}

void main()
{

	float remappedZ = remap(0.0, 1.0, minimumZ, maximumZ, mvPosition.z);

	gl_FragColor = vec4(remappedZ, remappedZ, remappedZ, 1);
}
