uniform sampler2D uNoiseTexture;
uniform float uTime;
uniform vec3 uInnerColor;
uniform vec3 uOuterColor;
uniform float uBrightness;
uniform float uvXTimeFrequency;
uniform float uvYTimeFrequency;

// Yeni Doppler uniformları
uniform float uDopplerStrength;
uniform float uDopplerColorShift;
uniform float uSpinDirection; // +1.0 veya -1.0 (disk dönüş yönüne göre)

varying vec2 vUv;
varying vec3 vWorldPosition;

void main() {
    vec3 color = mix(uInnerColor, uOuterColor, vUv.y);

    // Edge Fade
    float innerFade = smoothstep(0.0, 0.08, vUv.y);
    float outerFade = 1.0 - smoothstep(0.9, 1.0, vUv.y);
    float edgeFade = innerFade * outerFade;

    // First Layer: Noise Texture
    vec2 uv1 = vUv;
    uv1.x -= uTime * uvXTimeFrequency;
    uv1.y -= uTime * uvYTimeFrequency;
    float noise1 = texture2D(uNoiseTexture, uv1).r;

    // Second Layer: Noise Texture
    vec2 uv2 = vUv * vec2(1.0, 1.4);
    uv2.x -= uTime * uvXTimeFrequency;
    uv2.y += uTime * uvYTimeFrequency;
    float noise2 = texture2D(uNoiseTexture, uv2).r;

    float combinedNoise = noise1 * noise2 * uBrightness;

    // --- Doppler Parlaklığı (Relativistic Beaming) ---
    // Diskin XZ düzlemindeki teğet (dönüş) yönü
    vec3 tangent = normalize(vec3(-vWorldPosition.z, 0.0, vWorldPosition.x)) * uSpinDirection;
    // Pikselden kameraya bakan yön (cameraPosition Three.js'te yerleşiktir)
    vec3 viewDir = normalize(cameraPosition - vWorldPosition);

    // +1: kameraya yaklaşıyor, -1: kameradan uzaklaşıyor, 0: dik (üstten bakış)
    float doppler = dot(tangent, viewDir);

    // Kara deliğe yakın iç yörüngede hız daha yüksek olduğu için etki daha güçlü
    float speedFalloff = mix(1.0, 0.45, vUv.y);
    float dopplerEffect = doppler * uDopplerStrength * speedFalloff;

    // Parlaklık çarpanı (yaklaşan taraf parlar, uzaklaşan taraf sönükleşir)
    float beaming = pow(max(0.15, 1.0 + dopplerEffect), 3.0);

    // Hafif renk kayması (yaklaşan taraf sıcak/beyazımsı, uzaklaşan taraf koyu)
    vec3 hotShift = vec3(1.0, 0.92, 1.0);
    vec3 coolShift = uOuterColor * 0.45;
    color = mix(color, hotShift, clamp(doppler, 0.0, 1.0) * uDopplerColorShift);
    color = mix(color, coolShift, clamp(-doppler, 0.0, 1.0) * uDopplerColorShift);

    gl_FragColor = vec4(color * beaming, edgeFade * combinedNoise);
}