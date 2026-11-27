varying vec3 vWorldNormal;
varying vec3 vWorldPosition;

void main() {
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    vWorldPosition = modelPosition.xyz;
    vWorldNormal = normalize(mat3(modelMatrix) * normal);

    gl_Position = projectionMatrix * viewMatrix * modelPosition;
}