attribute float aSize;
attribute vec3 aColor;

varying vec3 vColor;
uniform float uSize;

void main(){
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    gl_PointSize = aSize * uSize * (1.0 / -viewPosition.z);

    //? Color
    vColor = aColor; 
}
