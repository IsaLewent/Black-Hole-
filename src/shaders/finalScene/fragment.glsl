uniform sampler2D uSpaceTexture;
uniform sampler2D uDistortionTexture;
uniform vec2 uBlackHolePosition;
uniform float uDistortionStrength;

varying vec2 vUv;

void main() {
    vec4 distortionColor = texture2D(uDistortionTexture, vUv);
    float distortionIntensity = distortionColor.r;

    vec2 towardCenter = vUv - uBlackHolePosition;
    towardCenter *= -distortionIntensity * uDistortionStrength;

    vec2 distortedUv = vUv + towardCenter;
    vec4 spaceColor = texture2D(uSpaceTexture, distortedUv);

    gl_FragColor = vec4(spaceColor.rgb, 1.0);
}