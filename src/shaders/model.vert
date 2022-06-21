#version 410

uniform	mat4 m_pvm, m_view;
uniform	mat3 m_normal;
uniform vec4 l_dir;
uniform float K, amp, tex;

in vec4 position;
in vec2 texCoord0;

out vec4 posV;
out vec2 texCoordV;

void main(void) {
    posV = position;
    texCoordV = texCoord0;
}