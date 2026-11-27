uniform vec3 uColor;
uniform float uIntensity;
uniform float uSharpness;
uniform float uTime;

varying vec3 vWorldNormal;
varying vec3 vWorldPosition;

void main() {
    vec3 normal = normalize(vWorldNormal);
    vec3 viewDir = normalize(cameraPosition - vWorldPosition);

    // Fresnel: merkezde 0.0 (tamamen görünmez), silüet kenarında 1.0
    float fresnel = 1.0 - clamp(dot(normal, viewDir), 0.0, 1.0);

    // 1. Katman: Jilet gibi ince foton halkası
    float thinRing = pow(fresnel, uSharpness);

    // 2. Katman: Çevresinde çok hafif yumuşak atmosfer parlaması
    float softHalo = pow(fresnel, uSharpness * 0.35) * 0.25;

    // Hafif canlı titreşim (enerji akışı hissi)
    float shimmer = 0.92 + 0.08 * sin(atan(vWorldPosition.y, vWorldPosition.x) * 6.0 - uTime * 2.5);

    float strength = (thinRing + softHalo) * shimmer;

    // Çekirdekte sıcak beyaza kayan parlak renk
    vec3 finalColor = mix(uColor, vec3(1.0, 0.95, 1.0), thinRing * 0.65);

    gl_FragColor = vec4(finalColor * uIntensity, strength);
}