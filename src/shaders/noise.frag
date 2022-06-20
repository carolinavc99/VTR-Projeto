#version 330

uniform	vec4 diffuse;
uniform sampler2D texGrass, texDirt;


in Data {
	vec2 texCoord1;
	vec3 normal;
	vec3 l_dir;
} DataIn;

out vec4 color;

void main(void) {
    float intensity, inclination;
    intensity = max(0.0, dot(normalize(DataIn.normal), normalize(DataIn.l_dir)));
    inclination = max(0.0, dot(normalize(DataIn.normal), vec3(0,1,0)));

	//outputF = intensity * diffuse + ambient;
    vec4 texture = (1-inclination) * texture(texDirt, DataIn.texCoord1) + inclination * texture(texGrass, DataIn.texCoord1);
	color = (intensity + 0.25) * texture;

}