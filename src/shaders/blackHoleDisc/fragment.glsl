uniform sampler2D uNoiseTexture;
uniform float uTime;
uniform vec3 uInnerColor;
uniform vec3 uOuterColor;
uniform float uBrightness;
uniform float uvXTimeFrequency;
uniform float uvYTimeFrequency;

varying vec2 vUv;

void main(){
    vec3 color = mix(uInnerColor, uOuterColor, vUv.y);

    //? Edge Fade
    float innerFade = smoothstep(0.0, 0.08, vUv.y);
    float outerFade = 1.0 -smoothstep(0.9, 1.0, vUv.y);
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

    // Combine the noise layers
    float combinedNoise = noise1 * noise2 * uBrightness;

    gl_FragColor = vec4(color, edgeFade * combinedNoise);
    // gl_FragColor = vec4(color, 1.0) * noiseColor;
}