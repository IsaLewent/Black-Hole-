uniform vec3 uColorA;
uniform vec3 uColorB;
uniform float uIntensity;
uniform float uScale;

varying vec3 vDirection;

#include "../partials/getPerlinNoise3d.glsl"

// 4 katmanlı Fractal Brownian Motion (FBM) bulut dokusu
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
    vec3 dir = normalize(vDirection);

    // İki farklı ölçekte bulut katmanı
    float baseCloud = fbm(dir * uScale);
    float detailCloud = fbm(dir * uScale * 2.2 + vec3(4.2, -1.7, 2.8));

    // Bulutların seyrek ve kontrastlı görünmesi için şekillendirme
    float nebulaMask = smoothstep(0.38, 0.78, baseCloud * 0.7 + detailCloud * 0.35);

    // Hafif bir galaksi ekvator bandı (diskle uyumlu derinlik)
    float galacticBand = 1.0 - smoothstep(0.0, 0.55, abs(dir.y));
    float finalMask = nebulaMask * (0.45 + 0.55 * galacticBand);

    // İki nebula rengini detay katmanına göre karıştır
    vec3 color = mix(uColorA, uColorB, smoothstep(0.3, 0.7, detailCloud));

    gl_FragColor = vec4(color * finalMask * uIntensity, 1.0);
}