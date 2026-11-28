uniform vec3 uColorA; // Elektrik mavisi (#0077ff)
uniform vec3 uColorB; // Canlı mor / magenta (#c038ff)
uniform float uIntensity;
uniform float uScale;

varying vec2 vUv;

const float PI = 3.14159265359;

// Hızlı 3D Hash + Value Noise (pnoise'dan ~4-5x hızlı, %100 organik)
float hash31(vec3 p) {
    p = fract(p * vec3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.x + p.y) * p.z);
}

float vnoise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    vec3 u = f * f * (3.0 - 2.0 * f);

    float n000 = hash31(i + vec3(0.0, 0.0, 0.0));
    float n100 = hash31(i + vec3(1.0, 0.0, 0.0));
    float n010 = hash31(i + vec3(0.0, 1.0, 0.0));
    float n110 = hash31(i + vec3(1.0, 1.0, 0.0));
    float n001 = hash31(i + vec3(0.0, 0.0, 1.0));
    float n101 = hash31(i + vec3(1.0, 0.0, 1.0));
    float n011 = hash31(i + vec3(0.0, 1.0, 1.0));
    float n111 = hash31(i + vec3(1.0, 1.0, 1.0));

    float nx00 = mix(n000, n100, u.x);
    float nx10 = mix(n010, n110, u.x);
    float nx01 = mix(n001, n101, u.x);
    float nx11 = mix(n011, n111, u.x);

    return mix(mix(nx00, nx10, u.y), mix(nx01, nx11, u.y), u.z) * 2.0 - 1.0;
}

const mat3 ROT = mat3(
     0.80,  0.48,  0.36,
    -0.60,  0.64,  0.48,
     0.00, -0.60,  0.80
);

// Yumuşak kozmik sis ve kıvrım vektörü
float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * (vnoise(p) * 0.5 + 0.5);
        p = ROT * p * 2.04 + vec3(1.7, -2.3, 0.9);
        a *= 0.5;
    }
    return v;
}

// Elektrikli plazma lifleri / şimşek damarları
float electricFbm(vec3 p) {
    float v = 0.0;
    float a = 0.55;
    float weight = 1.0;
    for (int i = 0; i < 5; i++) {
        float n = abs(vnoise(p));
        float ridge = 1.0 - n;
        ridge = ridge * ridge * ridge * weight;
        weight = clamp(ridge * 2.1, 0.15, 1.0);
        v += ridge * a;
        p = ROT * p * 2.15 + vec3(n * 0.8, -n * 0.6, n * 0.5);
        a *= 0.52;
    }
    return v;
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

    vec3 p = dir * uScale * 2.0;

    // 1. Organik duman kıvrımı (domain warp)
    vec3 q = vec3(
        fbm(p),
        fbm(p + vec3(4.3, 1.7, -2.1)),
        fbm(p + vec3(-2.8, 5.1, 3.4))
    );
    vec3 warped = p + 1.85 * (q - 0.5);

    // 2. Yumuşak gaz sisi + elektrikli plazma damarları
    float gas = fbm(warped * 0.85);
    float arcs = electricFbm(warped * 1.2);
    float fineSparks = electricFbm(warped * 2.3 + vec3(2.1, -1.4, 3.3));

    // Geniş sisli geçiş + derin uzay boşlukları
    float cloudMask = smoothstep(0.24, 0.82, gas * 0.72 + arcs * 0.45);
    float electricVeins = pow(clamp(arcs, 0.0, 1.0), 2.3) * 1.15
                        + pow(clamp(fineSparks, 0.0, 1.0), 3.0) * 0.85;

    // Geniş mavi ve mor bölgeler (düşük frekanslı bölgesel geçiş)
    float colorZone = smoothstep(0.30, 0.72, fbm(p * 0.45 + vec3(1.2, -0.8, 2.4)));
    vec3 baseColor = mix(uColorA, uColorB, colorZone);

    // Elektrikli damar sırtlarında yumuşak camgöbeği / lila-beyaz parlama
    vec3 hotCore = mix(vec3(0.50, 0.88, 1.0), vec3(0.98, 0.76, 1.0), colorZone);

    vec3 col = baseColor * cloudMask * 0.78
             + baseColor * electricVeins * cloudMask * 0.85
             + hotCore * pow(clamp(electricVeins, 0.0, 1.3), 2.4) * cloudMask * 0.58;

    col = pow(max(col, vec3(0.0)), vec3(1.12)) * uIntensity;
    gl_FragColor = vec4(col, 1.0);
}