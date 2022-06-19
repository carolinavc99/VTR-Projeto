#version 330

uniform	vec4 diffuse;

in Data {
	vec3 normal;
	vec3 l_dir;
} DataIn;

out vec4 color;

void main(void) {
    float intensity;
    intensity = max(0.0, dot(normalize(DataIn.normal), normalize(DataIn.l_dir)));

	//outputF = intensity * diffuse + ambient;
	color = (intensity + 0.25) * diffuse;

}