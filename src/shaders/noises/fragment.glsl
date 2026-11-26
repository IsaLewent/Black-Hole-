varying vec2 vUv;

#include "../partials/getPerlinNoise3d.glsl"

void main(){
    float noise = pnoise(vec3(vUv * 8.0, 0.0), vec3(8.0)) * 0.5 + 0.5;
    gl_FragColor = vec4(vec3(noise), 1.0);
}