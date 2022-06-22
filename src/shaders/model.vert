#version 410

in vec4 position;
in vec2 texCoord0;

out vec4 posV;
out vec2 texCoordV;

void main(void) {
    posV = position;
    texCoordV = texCoord0;
}