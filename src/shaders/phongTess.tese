#version 410

layout(triangles, fractional_odd_spacing, ccw) in;

uniform	mat4 projViewModelMatrix;
uniform	mat3 normalMatrix;

uniform float alpha = 0.75;

in vec4 normalTC[];
in vec4 posTC[];

out vec3 normalTE;



void main() {

	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	float w = gl_TessCoord.z;

	// compute normal as the weighted average of the normals for each vertex
	vec3 normalTE = vec3( normalTC[0] * u
						+ normalTC[1] * v
						+ normalTC[2] * w);

	// compute point as weighted average of triangle vertices
	vec4 P = vec4( posTC[0] * u
				 + posTC[1] * v
				 + posTC[2] * w);
	
	// compute the projected points
	vec4 P0 = P - normalTC[0] * dot(P-posTC[0], normalTC[0]);
	vec4 P1 = P - normalTC[1] * dot(P-posTC[1], normalTC[1]);
	vec4 P2 = P - normalTC[2] * dot(P-posTC[2], normalTC[2]);

	// compute the weighted average of the projected points
	vec4 PS = vec4( P0 * u
				  + P1 * v
				  + P2 * w);

	// compute final point as a linear interpolation between P and PS with factor alpha
	vec4 res = alpha * P + (1-alpha) * PS;

	gl_Position = projViewModelMatrix *  res;
}

