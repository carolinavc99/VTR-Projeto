#version 330

uniform	mat4 m_pvm, m_view;
uniform	mat3 m_normal;
uniform vec4 l_dir;
uniform float K, amp;

in vec4 position;
in vec2 texCoord0;

out Data {
	vec2 texCoord1;
	vec3 normal;
	vec3 l_dir;
} DataOut;

vec2 grad( ivec2 z )  // replace this anything that returns a random vector
{
    // 2D to 1D  (feel free to replace by some other)
    int n = z.x+z.y*11111;

    // Hugo Elias hash (feel free to replace by another one)
    n = (n<<13)^n;
    n = (n*(n*n*15731+789221)+1376312589)>>16;


    // simple random vectors
    return vec2(cos(float(n)),sin(float(n)));


}

float noise( in vec2 p )
{
    //return sin(p.x);
    ivec2 i = ivec2(floor( p ));
     vec2 f =       fract( p );
    
    vec2 u = f*f*(3.0-2.0*f); // feel free to replace by a quintic smoothstep instead

    return mix( mix( dot( grad( i+ivec2(0,0) ), f-vec2(0.0,0.0) ), 
                     dot( grad( i+ivec2(1,0) ), f-vec2(1.0,0.0) ), u.x),
                mix( dot( grad( i+ivec2(0,1) ), f-vec2(0.0,1.0) ), 
                     dot( grad( i+ivec2(1,1) ), f-vec2(1.0,1.0) ), u.x), u.y);
}

float getheight( in vec2 uv ) {
    return amp * noise(K*uv);
}

void main(void) {
    vec2 uv = vec2(0.001*(position.x), 0.001*(position.z));
    vec2 uv1 = vec2(0.001*(position.x), 0.001*(position.z-64/K));
    vec2 uv2 = vec2(0.001*(position.x), 0.001*(position.z+64/K));
    vec2 uv3 = vec2(0.001*(position.x-64/K), 0.001*(position.z));
    vec2 uv4 = vec2(0.001*(position.x+64/K), 0.001*(position.z));



    float f  = getheight(uv);
    float f1 = getheight(uv1);
    float f2 = getheight(uv2);
    float f3 = getheight(uv3);
    float f4 = getheight(uv4);

    vec4 pos = vec4(position.x, f, position.z, 1);
    vec4 pos1 = vec4(position.x, f1, position.z-64/K, 1);
    vec4 pos2 = vec4(position.x, f2, position.z+64/K, 1);
    vec4 pos3 = vec4(position.x-64/K, f3, position.z, 1);
    vec4 pos4 = vec4(position.x+64/K, f4, position.z, 1);

	// Pass-through the texture coordinates
	DataOut.texCoord1 = texCoord0;

	// Pass-through the normal and light direction
	DataOut.normal = normalize(m_normal * normalize(cross(vec3(pos2-pos1), vec3(pos4-pos3))));
	DataOut.l_dir = normalize(vec3(m_view * -l_dir));

	// transform the vertex coordinates
	gl_Position = m_pvm * pos;
}