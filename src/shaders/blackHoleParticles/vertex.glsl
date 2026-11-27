uniform float uTime;
uniform float uSize;
uniform float uParticlesSpeed;

attribute float aSize;
attribute float aAngle;
attribute float aDistance;

varying float vProgress;


void main(){
    float speed = 1.2 / pow(aDistance, 2.3) * uParticlesSpeed * 4.0;
    float angle = aAngle + uTime * (0.4 * aDistance) * 0.4 * speed;
    vec3 pos = position;
    pos.x = cos(angle) * aDistance;
    pos.z = sin(angle) * aDistance;

    float progress = (aDistance - 1.0) / 4.0;

    vec4 modelPosition = modelMatrix * vec4(pos, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    gl_PointSize = aSize * uSize * (1.0 / -viewPosition.z);
    
    // Varyings
    vProgress = progress;
}