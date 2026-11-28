uniform vec3 uColorA; // Elektrik mavisi (#0b66ff)
uniform vec3 uColorB; // Canlı mor/magenta (#c038ff)
uniform float uIntensity;
uniform float uScale;

varying vec2 vUv;

#include "../partials/getPerlinNoise3d.glsl"

const float PI = 3.14159265359;

// Yumuşak temel bulut FBM
float fbm(vec3 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < 5; i++) {
        value += amplitude * (pnoise(p * frequency, vec3(16.0)) * 0.5 + 0.5);
        frequency *= 2.03;
        amplitude *= 0.5;
    }
    return value;
}

// İpeksi duman damarları üreten Ridged FBM
float ridgedFbm(vec3 p) {
    float value = 0.0;
    float amplitude = 0.55;
    float frequency = 1.0;
    float weight = 1.0;

    for (int i = 0; i < 5; i++) {
        float n = 1.0 - abs(pnoise(p * frequency, vec3(16.0)));
        n = n * n * weight;
        weight = clamp(n * 1.8, 0.0, 1.0);
        value += n * amplitude;
        frequency *= 2.12;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    // 2D UV -> 360° dikişsiz küresel yön vektörü
    float theta = vUv.x * 2.0 * PI;
    float phi = (1.0 - vUv.y) * PI;
    vec3 dir = vec3(
        sin(phi) * cos(theta),
        cos(phi),
        sin(phi) * sin(theta)
    );

    vec3 p = dir * uScale;

    // 1. Aşama Domain Warping: duman kıvrımları oluşturur
    vec3 q = vec3(
        fbm(p + vec3(0.0, 0.0, 0.0)),
        fbm(p + vec3(5.2, 1.3, 2.8)),
        fbm(p + vec3(-2.4, 3.7, 1.5))
    );

    // 2. Aşama Domain Warping: ince akışkan şeritler
    vec3 r = vec3(
        fbm(p + 2.6 * q + vec3(1.7, 9.2, 4.1)),
        fbm(p + 2.6 * q + vec3(8.3, 2.8, -3.5)),
        fbm(p + 2.6 * q + vec3(-4.1, -1.9, 6.2))
    );

    // Yumuşak gaz gövdesi + keskin ipeksi damarlar
    float gasBody = fbm(p + 2.2 * r);
    float wisps = ridgedFbm(p * 1.35 + 2.4 * r);

    // Koyu uzay boşluklarını koruyan kontrast maskesi
    float density = smoothstep(0.28, 0.82, gasBody * 0.65 + wisps * 0.55);
    float filaments = pow(clamp(wisps, 0.0, 1.0), 2.4);

    // Mavi ve mor bölgeleri bükülmüş katmanlara göre ayır
    float colorMix = smoothstep(0.25, 0.78, q.x * 0.6 + r.y * 0.4);
    vec3 baseColor = mix(uColorA, uColorB, colorMix);

    // En keskin duman sırtlarına sıcak beyaz-lila / camgöbeği parlama ekle
    vec3 highlightTint = mix(vec3(0.55, 0.88, 1.0), vec3(1.0, 0.82, 1.0), colorMix);
    vec3 finalColor = baseColor * density * 0.9 + highlightTint * filaments * density * 1.15;

    // Derin siyah uzay kontrastı
    finalColor = pow(max(finalColor, vec3(0.0)), vec3(1.15)) * uIntensity;

    gl_FragColor = vec4(finalColor, 1.0);
}