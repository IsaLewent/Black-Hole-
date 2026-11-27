varying vec3 vDirection;
varying vec2 vUv;

void main() {
    vDirection = normalize(position);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    // Varyings
    vUv = uv;
}