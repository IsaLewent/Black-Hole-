uniform float uDistortionRadius;
uniform float uDistortionInnerValue;

varying vec2 vUv;

float inverseLerp(float v, float minValue, float maxValue) {
    return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

void main() {
    float distanceToCenter = length(vUv - 0.5);
    float radialStrength = remap(distanceToCenter, 0.0, uDistortionRadius , uDistortionInnerValue, 0.0);
    radialStrength = smoothstep(0.0, 1.0, radialStrength);

    gl_FragColor = vec4(radialStrength, 1.0, 1.0, 1.0);
}