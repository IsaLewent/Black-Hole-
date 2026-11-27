uniform vec3 uColorA;
uniform vec3 uColorB;
uniform float uIntensity;
uniform float uScale;

varying vec2 vUv;

#include "../partials/getPerlinNoise3d.glsl"

const float PI = 3.14159265359;

float fbm(vec3 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < 4; i++) {
        value += amplitude * (pnoise(p * frequency, vec3(16.0)) * 0.5 + 0.5);
        frequency *= 2.05;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    // 2D UV'yi 360° küresel 3D yön vektörüne çevir (dikişsiz)
    float theta = vUv.x * 2.0 * PI;
    float phi = (1.0 - vUv.y) * PI;
    vec3 dir = vec3(
        sin(phi) * cos(theta),
        cos(phi),
        sin(phi) * sin(theta)
    );

    float baseCloud = fbm(dir * uScale);
    float detailCloud = fbm(dir * uScale * 2.2 + vec3(4.2, -1.7, 2.8));

    float nebulaMask = smoothstep(0.38, 0.78, baseCloud * 0.7 + detailCloud * 0.35);
    float galacticBand = 1.0 - smoothstep(0.0, 0.55, abs(dir.y));
    float finalMask = nebulaMask * (0.45 + 0.55 * galacticBand);

    vec3 color = mix(uColorA, uColorB, smoothstep(0.3, 0.7, detailCloud));
    gl_FragColor = vec4(color * finalMask * uIntensity, 1.0);
}