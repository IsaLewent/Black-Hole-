varying vec3 vColor;

void main(){
    vec2 uv = gl_PointCoord;
    float dist = length(uv - vec2(0.5));
    float alpha = 1.0 - smoothstep(0.4,0.5,dist);

    gl_FragColor = vec4(vec3(1.0), alpha);
}