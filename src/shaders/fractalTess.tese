#version 410

layout(triangles, fractional_odd_spacing, ccw) in;

uniform	mat4 m_pvm, m_view;
uniform	mat3 m_normal;
uniform vec4 l_dir;
uniform float K, amp2, tex;


in vec2 texCoordTC[];
in vec4 posTC[];

out Data {
	vec2 texCoord1;
	vec3 normal;
	vec3 l_dir;
} DataOut;

vec3 randomnoise33(vec3 p)
{
    return (fract(sin(p + dot(p, vec3(12.9898, 78.233, 195.1533))) * 43758.5453123) * 2.0) - 1.0;
}

float gdot31(vec3 p, vec3 i)
{
    return dot(p - i, vec3(sin(randomnoise33(i) * 2920.0)));
}

float perlinnoise31(vec3 p)
{
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * f * ((f * ((f * 6.0) - 15.0)) + 10.0);
    return mix(mix(mix(gdot31(p, i                      ),
                       gdot31(p, i + vec3(1.0, 0.0, 0.0)), f.x),
                   mix(gdot31(p, i + vec3(0.0, 1.0, 0.0)),
                       gdot31(p, i + vec3(1.0, 1.0, 0.0)), f.x), f.y),
               mix(mix(gdot31(p, i + vec3(0.0, 0.0, 1.0)),
                       gdot31(p, i + vec3(1.0, 0.0, 1.0)), f.x),
                   mix(gdot31(p, i + vec3(0.0, 1.0, 1.0)),
                       gdot31(p, i + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
}

float fractalperlinnoise31(vec3 p, float amplitude, float frequency, float gain, float lacunarity, int octaves)
{
    float r = 0.0;
    float a = amplitude;
    float f = frequency;
    for(int i = 0; i < octaves; i++)
    {
        r += perlinnoise31(p * f) * a;
        a *= gain;
        f *= lacunarity;
    }
    return r;
}

float getheight( in vec2 uv ) {
    int octaves = 8;
    vec3 offs = vec3(
        fractalperlinnoise31(vec3(uv, 0.0) + 697.486, 0.5, 1.0, 0.5, 2.0, octaves),
        fractalperlinnoise31(vec3(uv, 0.0) + 120.165, 0.5, 1.0, 0.5, 2.0, octaves),
        fractalperlinnoise31(vec3(uv, 0.0) + 892.858, 0.5, 1.0, 0.5, 2.0, octaves)
    ) * 2.0 * (0.5 + (0.5 * perlinnoise31(vec3(uv, 526.628))));

    float smoothen = 0.5 + (0.5 * perlinnoise31(vec3(uv * 0.5, 0.0) + 259.562));

    float roughHeight = 0.5 + (0.5 * fractalperlinnoise31(vec3(uv, 0.0) + offs, 0.5, 1.0, 0.5, 2.0, 16));

    float smoothHeight = 0.5 + (0.5 * fractalperlinnoise31(vec3(uv * 0.5, 0.0), 0.5, 1.0, 0.5, 2.0, 8));

    float result = mix(roughHeight, smoothHeight * 0.5, 1.0 - (smoothen * smoothen));

    result *= 1.6;

    return amp2 * 3 * result * result * result;
}

void main() {

	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	float w = gl_TessCoord.z;

	// compute point as weighted average of triangle vertices
	vec4 P = vec4( posTC[0] * u
				 + posTC[1] * v
				 + posTC[2] * w);

	vec2 texCoord = vec2( texCoordTC[0] * u
						+ texCoordTC[1] * v
						+ texCoordTC[2] * w);

	float offset = 16;
	float scale = 0.001;
	vec2 uv =  scale * P.xz;
	vec2 uv1 = uv - scale * vec2(0, offset);
	vec2 uv2 = uv + scale * vec2(0, offset);
	vec2 uv3 = uv - scale * vec2(offset, 0);
	vec2 uv4 = uv + scale * vec2(offset, 0);

    float f  = getheight(uv);
    float f1 = getheight(uv1);
    float f2 = getheight(uv2);
    float f3 = getheight(uv3);
    float f4 = getheight(uv4);

    vec4 pos = vec4(P.x, f, P.z, 1);
    vec4 pos1 = vec4(P.x, f1, P.z-offset, 1);
    vec4 pos2 = vec4(P.x, f2, P.z+offset, 1);
    vec4 pos3 = vec4(P.x-offset, f3, P.z, 1);
    vec4 pos4 = vec4(P.x+offset, f4, P.z, 1);

	// Pass-through the texture coordinates
	DataOut.texCoord1 = texCoord * tex;

	// Pass-through the normal and light direction
	DataOut.normal = normalize(m_normal * normalize(cross(vec3(pos2-pos1), vec3(pos4-pos3))));
	DataOut.l_dir = normalize(vec3(m_view * -l_dir));

	// transform the vertex coordinates
	gl_Position = m_pvm * pos;
}

