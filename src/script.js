import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";

import { Pane } from "tweakpane";

//* Shaders
//? Stars Shaders
import starsVertexShader from "./shaders/stars/vertex.glsl";
import starsFragmentShader from "./shaders/stars/fragment.glsl";

//? Noises Shaders
import noisesVertexShader from "./shaders/noises/vertex.glsl";
import noisesFragmentShader from "./shaders/noises/fragment.glsl";

//? Black Hole Disc Shaders
import blackHoleDiscVertexShader from "./shaders/blackHoleDisc/vertex.glsl";
import blackHoleDisxFragmentShader from "./shaders/blackHoleDisc/fragment.glsl";

//? Black Hole Particles Shaders
import blackHoleParticlesVertexShader from "./shaders/blackHoleParticles/vertex.glsl";
import blackHoleParticlesFragmentShader from "./shaders/blackHoleParticles/fragment.glsl";

//? Black Hole Distortion Active Shaders
import blackHoleDistortionActiveVertexShader from "./shaders/blackHoleDistortionActive/vertex.glsl";
import blackHoleDistortionActiveFragmentShader from "./shaders/blackHoleDistortionActive/fragment.glsl";

//? Black Hole Distortion Mask Shaders
import blackHoleDistortionMaskVertexShader from "./shaders/blackHoleDistortionMask/vertex.glsl";
import blackHoleDistortionMaskFragmentShader from "./shaders/blackHoleDistortionMask/fragment.glsl";

//? Black Hole Final Scene Shaders
import blackHoleFinalSceneVertexShader from "./shaders/finalScene/vertex.glsl";
import blackHoleFinalSceneFragmentShader from "./shaders/finalScene/fragment.glsl";

//? Debug Location Hash
const debugLocationHash = window.location.hash === "#debug";

//? Debug UI
let pane = null;
if (debugLocationHash) {
    pane = new Pane({ title: "Settings", expanded: true });
}

//? UI Parameters
const params = {
    starsSize: 1.5,
    particlesSize: 39.2,

    brightness: 3.5,
    uvXTimeFrequency: 0.26,
    uvYTimeFrequency: 0.17,
    particlesSpeed: 15.9,

    innerColor: `#fff9f9`,
    outerColor: `#1510a7`,

    distortionStrength: 2.0,
    distortionRadius: 0.20,
    distortionInnerValue: 1.4,

};
let nonStringInnerColor = params.innerColor.replace("`#", "0x");
let nonStringOuterColor = params.outerColor.replace("`#", "0x");


//? Canvas
const canvas = document.querySelector("canvas.webgl");

//? Scenes
const spaceScene = new THREE.Scene();
const distortionScene = new THREE.Scene();
const finalScene = new THREE.Scene();

//? Sizes
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight,
    pixelRatio: Math.min(window.devicePixelRatio, 2),
};

//? Cursor
const cursor = {
    x: 0,
    y: 0,
};

//? Camera
const aspectRatio = sizes.width / sizes.height;
const camera = new THREE.PerspectiveCamera(
    45,
    aspectRatio,
    0.1,
    1000,
);
camera.position.set(-0.9950781030013188, 5.4978031828700376, 11.536204514917294);
camera.rotation.set(-0.44472812594572336, -0.07770975381383101, -0.03697996976497322);
spaceScene.add(camera);

const finalCamera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);

//? Setup The Controls
const controls = new OrbitControls(camera, canvas);
controls.enableDamping = true;

//* Stars
//? Stars Geometry
const starsGeometry = new THREE.BufferGeometry();
const starsCount = 50000;
const starsPosition = new Float32Array(starsCount * 3);
const randomSize = new Float32Array(starsCount);
const randomColor = new Float32Array(starsCount * 3);

for (let i = 0; i < starsCount; i++) {
    const i3 = i * 3;
    const theta = Math.random() * 2 * Math.PI;
    const phi = Math.acos(2 * Math.random() - 1);
    const radius = 600; // Random radius between 100 and 500

    //? Spherical to Cartesian conversion
    starsPosition[i3 + 0] = radius * Math.sin(phi) * Math.cos(theta);
    starsPosition[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
    starsPosition[i3 + 2] = radius * Math.cos(phi);

    //? Random Size
    randomSize[i] = Math.random() * 2 + 0.5; // Random size between 0.5 and 2.5

    //? Random Color
    randomColor[i3 + 0] = Math.random(); // Red channel
    randomColor[i3 + 1] = Math.random(); // Green channel
    randomColor[i3 + 2] = Math.random(); // Blue channel
}
starsGeometry.setAttribute("position", new THREE.BufferAttribute(starsPosition, 3));
starsGeometry.setAttribute("aSize", new THREE.BufferAttribute(randomSize, 1));
starsGeometry.setAttribute("aColor", new THREE.BufferAttribute(randomColor, 3));

//? Stars Material
const starsMaterial = new THREE.ShaderMaterial({
    uniforms: {
        uSize: { value: params.starsSize },
    },
    vertexShader: starsVertexShader,
    fragmentShader: starsFragmentShader,
    transparent: true,
    depthTest: false,
    depthWrite: false,
    blending: THREE.AdditiveBlending,
});

//? Stars Points
const stars = new THREE.Points(starsGeometry, starsMaterial);
spaceScene.add(stars);

//? Noise Render Target
const noiseRenderTarget = new THREE.WebGLRenderTarget(256, 256, {
    generateMipmaps: false,
    minFilter: THREE.LinearFilter,
    magFilter: THREE.LinearFilter,
    wrapS: THREE.RepeatWrapping,
    wrapT: THREE.RepeatWrapping,
});

//? Noise Scene
const noiseScene = new THREE.Scene();
const noiseCamera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.0, 10);
noiseCamera.position.set(0, 0, 1);
const noiseGeometry = new THREE.PlaneGeometry(2, 2);
const noiseMaterial = new THREE.ShaderMaterial({
    vertexShader: noisesVertexShader,
    fragmentShader: noisesFragmentShader,
});
const noiseMesh = new THREE.Mesh(noiseGeometry, noiseMaterial);
noiseScene.add(noiseMesh);

//? Noise Texture
const noiseTexture = noiseRenderTarget.texture;
noiseTexture.wrapS = THREE.RepeatWrapping;
noiseTexture.wrapT = THREE.RepeatWrapping;

//? BlackHole Disc
const discGeomtry = new THREE.CylinderGeometry(5, 1, 0, 128, 32, true);
const discMaterial = new THREE.ShaderMaterial({
    vertexShader: blackHoleDiscVertexShader,
    fragmentShader: blackHoleDisxFragmentShader,
    uniforms: {
        uNoiseTexture: { value: noiseTexture },
        uTime: { value: 0.0 },
        uInnerColor: { value: new THREE.Color(nonStringInnerColor) },
        uOuterColor: { value: new THREE.Color(nonStringOuterColor) },
        uBrightness: { value: 3.5 },
        uvXTimeFrequency: { value: 0.31 },
        uvYTimeFrequency: { value: 0.09 },
    },
    side: THREE.DoubleSide,
    transparent: true,
    depthTest: false,
    depthWrite: false,
    blending: THREE.AdditiveBlending,
});
const disc = new THREE.Mesh(discGeomtry, discMaterial);
disc.rotation.x = Math.PI;
spaceScene.add(disc);

//? Black Hole
const blackHoleGeometry = new THREE.SphereGeometry(1, 64, 64);
const blackHoleMaterial = new THREE.MeshBasicMaterial({ color: "black" });
const blackHole = new THREE.Mesh(blackHoleGeometry, blackHoleMaterial);
// spaceScene.add(blackHole);

//* Black Hole Particles
//? Particles Geometry
const particlesCount = 70000;
const particlesGeometry = new THREE.BufferGeometry();
const particlesPosition = new Float32Array(particlesCount * 3);
const particlesDistance = new Float32Array(particlesCount);
const particlesAngle = new Float32Array(particlesCount);
const particlesSize = new Float32Array(particlesCount);

for (let i = 0; i < particlesCount; i++) {
    const i3 = i * 3;
    particlesDistance[i] = 1.0 + Math.pow(Math.random(), 2.0) * 4.0;
    particlesAngle[i] = Math.random() * Math.PI * 2;
    particlesSize[i] = Math.random();

    //? Position
    const randomY = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1);
    particlesPosition[i3 + 0] = 0;
    particlesPosition[i3 + 1] = randomY * 0.05;
    particlesPosition[i3 + 2] = 0;
}
particlesGeometry.setAttribute("position", new THREE.BufferAttribute(particlesPosition, 3));
particlesGeometry.setAttribute("aDistance", new THREE.BufferAttribute(particlesDistance, 1));
particlesGeometry.setAttribute("aAngle", new THREE.BufferAttribute(particlesAngle, 1));
particlesGeometry.setAttribute("aSize", new THREE.BufferAttribute(particlesSize, 1));

const particlesMaterial = new THREE.ShaderMaterial({
    vertexShader: blackHoleParticlesVertexShader,
    fragmentShader: blackHoleParticlesFragmentShader,
    uniforms: {
        uTime: { value: 0.0 },
        uSize: { value: params.particlesSize },
        uParticlesSpeed: { value: params.particlesSpeed },
        uInnerColor: { value: new THREE.Color(nonStringInnerColor) },
        uOuterColor: { value: new THREE.Color(nonStringOuterColor) },
    },
    transparent: true,
    depthTest: false,
    depthWrite: false,
    blending: THREE.AdditiveBlending,
});
const particles = new THREE.Points(particlesGeometry, particlesMaterial);
spaceScene.add(particles);

//* Black Hole Distortion (Camera-Angle Billboard + Horizontal Disc Mask)
const distortionActiveGeometry = new THREE.PlaneGeometry(2, 2);
const distortionActiveMaterial = new THREE.ShaderMaterial({
    vertexShader: blackHoleDistortionActiveVertexShader,
    fragmentShader: blackHoleDistortionActiveFragmentShader,
    uniforms: {
        uDistortionRadius: { value: params.distortionRadius },
        uDistortionInnerValue: { value: params.distortionInnerValue },
    },
    side: THREE.DoubleSide,
    transparent: true,
});
const distortionActive = new THREE.Mesh(distortionActiveGeometry, distortionActiveMaterial);
distortionActive.scale.set(5, 5, 5);
distortionScene.add(distortionActive);

const distortionMaskGeometry = new THREE.PlaneGeometry(1, 1);
const distortionMaskMaterial = new THREE.ShaderMaterial({
    vertexShader: blackHoleDistortionMaskVertexShader,
    fragmentShader: blackHoleDistortionMaskFragmentShader,
    uniforms: {
        uDistortionRadius: { value: params.distortionRadius },
        uDistortionInnerValue: { value: params.distortionInnerValue },
    },
    side: THREE.DoubleSide,
    transparent: true,
});
const distortionMask = new THREE.Mesh(distortionMaskGeometry, distortionMaskMaterial);
distortionMask.scale.set(10, 10, 10);
distortionMask.rotation.x = Math.PI * 0.5;
distortionScene.add(distortionMask);

//* Render Targets (Space & Distortion)
const spaceRenderTarget = new THREE.WebGLRenderTarget(
    sizes.width * sizes.pixelRatio,
    sizes.height * sizes.pixelRatio,
    {
        minFilter: THREE.LinearFilter,
        magFilter: THREE.LinearFilter,
        colorSpace: THREE.SRGBColorSpace,
    },
);

const distortionRenderTarget = new THREE.WebGLRenderTarget(
    Math.max(1, Math.floor(sizes.width * 0.5)),
    Math.max(1, Math.floor(sizes.height * 0.5)),
    {
        minFilter: THREE.LinearFilter,
        magFilter: THREE.LinearFilter,
        colorSpace: THREE.SRGBColorSpace,
    },
);

//* Final Composition Scene (Gravitational Lensing, No RGB Shift)
const finalGeometry = new THREE.PlaneGeometry(2, 2);
const finalMaterial = new THREE.ShaderMaterial({
    vertexShader: blackHoleFinalSceneVertexShader,
    fragmentShader: blackHoleFinalSceneFragmentShader,
    uniforms: {
        uSpaceTexture: { value: spaceRenderTarget.texture },
        uDistortionTexture: { value: distortionRenderTarget.texture },
        uBlackHolePosition: { value: new THREE.Vector2(0.5, 0.5) },
        uDistortionStrength: { value: params.distortionStrength },
    },
    depthWrite: false,
    depthTest: false,
});
const finalMesh = new THREE.Mesh(finalGeometry, finalMaterial);
finalScene.add(finalMesh);

//? Renderer
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true,
});

renderer.setRenderTarget(noiseRenderTarget);
renderer.render(noiseScene, noiseCamera);
renderer.setRenderTarget(null);
renderer.setSize(sizes.width, sizes.height);
renderer.setPixelRatio(sizes.pixelRatio);
renderer.setClearColor("#000000");

//? General Black Hole GUI
if (pane) {
    const blackHoleFolder = pane.addFolder({ title: "Black Hole" });
    blackHoleFolder.addBinding(params, "innerColor", { label: "Inner Color" }).on("change", (ev) => {
        nonStringInnerColor = ev.value.replace("`#", "0x");
        discMaterial.uniforms.uInnerColor.value.set(nonStringInnerColor);
        particlesMaterial.uniforms.uInnerColor.value.set(nonStringInnerColor);
        params.innerColor = ev.value;
    });
    blackHoleFolder.addBinding(params, "outerColor", { label: "Outer Color" }).on("change", (ev) => {
        nonStringOuterColor = ev.value.replace("`#", "0x");
        discMaterial.uniforms.uOuterColor.value.set(nonStringOuterColor);
        particlesMaterial.uniforms.uOuterColor.value.set(nonStringOuterColor);
        params.outerColor = ev.value;
    });
    blackHoleFolder.addBinding(params, "starsSize", { label: "Stars Size", min: 0.1, max: 400.0, step: 0.1 }).on("change", (ev) => {
        starsMaterial.uniforms.uSize.value = ev.value;
        params.starsSize = ev.value;
    });
    blackHoleFolder.addBinding(params, "particlesSize", { label: "Particles Size", min: 0.1, max: 400.0, step: 0.1 }).on("change", (ev) => {
        particlesMaterial.uniforms.uSize.value = ev.value;
        params.particlesSize = ev.value;
    });
    blackHoleFolder.addBinding(params, "brightness", { label: "Brightness", min: 0.1, max: 10.0, step: 0.1 }).on("change", (ev) => {
        discMaterial.uniforms.uBrightness.value = ev.value;
        params.brightness = ev.value;
    });
    blackHoleFolder.addBinding(params, "uvXTimeFrequency", { label: "Black Hole X Direction Speed", min: 0.01, max: 1.0, step: 0.01 }).on("change", (ev) => {
        discMaterial.uniforms.uvXTimeFrequency.value = ev.value;
        params.uvXTimeFrequency = ev.value;
    });
    blackHoleFolder.addBinding(params, "uvYTimeFrequency", { label: "Black Hole Y Direction Speed", min: 0.01, max: 1.0, step: 0.01 }).on("change", (ev) => {
        discMaterial.uniforms.uvYTimeFrequency.value = ev.value;
        params.uvYTimeFrequency = ev.value;
    });
    blackHoleFolder.addBinding(params, "particlesSpeed", { label: "Particles Speed", min: 0.1, max: 50.0, step: 0.1 }).on("change", (ev) => {
        particlesMaterial.uniforms.uParticlesSpeed.value = ev.value;
        params.particlesSpeed = ev.value;
    });
    blackHoleFolder.addBinding(params, "distortionStrength", { label: "Black Hole Distortion Strength", min: 0.1, max: 5.0, step: 0.1 }).on("change", (ev) => {
        finalMaterial.uniforms.uDistortionStrength.value = ev.value;
        params.distortionStrength = ev.value;
    });
    blackHoleFolder.addBinding(params, "distortionRadius", { label: "Black Hole Distortion Radius", min: 0.01, max: 1.0, step: 0.01 }).on("change", (ev) => {
        distortionActiveMaterial.uniforms.uDistortionRadius.value = ev.value;
        distortionMaskMaterial.uniforms.uDistortionRadius.value = ev.value;
        params.distortionRadius = ev.value;
    });
    blackHoleFolder.addBinding(params, "distortionInnerValue", { label: "Black Hole Distortion Inner Value", min: 0.1, max: 5.0, step: 0.1 }).on("change", (ev) => {
        distortionActiveMaterial.uniforms.uDistortionInnerValue.value = ev.value;
        distortionMaskMaterial.uniforms.uDistortionInnerValue.value = ev.value;
        params.distortionInnerValue = ev.value;
    });
}

//? Black Hole Screen Position
const blackHoleScreenPosition = new THREE.Vector3();

//? Animate
const clock = new THREE.Timer();
const tick = () => {
    controls.update();

    clock.update();
    const elapsedTime = clock.getElapsed();

    discMaterial.uniforms.uTime.value = elapsedTime;
    particlesMaterial.uniforms.uTime.value = elapsedTime;

    // Billboard distortion active plane toward the camera
    distortionActive.lookAt(camera.position);

    // Project black hole world origin (0, 0, 0) into screen UV [0, 1]
    blackHoleScreenPosition.set(0, 0, 0);
    blackHoleScreenPosition.project(camera);
    blackHoleScreenPosition.x = blackHoleScreenPosition.x * 0.5 + 0.5;
    blackHoleScreenPosition.y = blackHoleScreenPosition.y * 0.5 + 0.5;
    finalMaterial.uniforms.uBlackHolePosition.value.set(
        blackHoleScreenPosition.x,
        blackHoleScreenPosition.y,
    );

    // Pass 1: Render Space Scene
    renderer.setRenderTarget(spaceRenderTarget);
    renderer.render(spaceScene, camera);

    // Pass 2: Render Distortion Map
    renderer.setRenderTarget(distortionRenderTarget);
    renderer.render(distortionScene, camera);

    // Pass 3: Render Final Composition to Screen
    renderer.setRenderTarget(null);
    renderer.render(finalScene, finalCamera);

    window.requestAnimationFrame(tick);
};

tick();

//! Resize
window.addEventListener("resize", () => {
    sizes.width = window.innerWidth;
    sizes.height = window.innerHeight;
    sizes.pixelRatio = Math.min(window.devicePixelRatio, 2);

    camera.aspect = sizes.width / sizes.height;
    camera.updateProjectionMatrix();

    renderer.setSize(sizes.width, sizes.height);
    renderer.setPixelRatio(sizes.pixelRatio);

    spaceRenderTarget.setSize(
        sizes.width * sizes.pixelRatio,
        sizes.height * sizes.pixelRatio,
    );
    distortionRenderTarget.setSize(
        Math.max(1, Math.floor(sizes.width * 0.5)),
        Math.max(1, Math.floor(sizes.height * 0.5)),
    );
});