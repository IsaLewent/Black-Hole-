uniform vec3 uInnerColor;
uniform vec3 uOuterColor;

varying float vProgress;

void main(){
    vec2 uv = gl_PointCoord * 2.0 - 1.0;
    float disc = length(uv - vec2(0.5));
    float alpha = smoothstep(0.5, 0.45, disc);


    vec3 color = mix(uInnerColor, uOuterColor, vProgress);
    
    gl_FragColor = vec4(color, alpha);
}